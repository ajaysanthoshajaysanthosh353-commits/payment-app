import os
import re
from typing import Any, Dict, List, Optional

from fastapi import Depends, FastAPI, Header, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, field_validator, model_validator

try:
    import firebase_admin
    from firebase_admin import auth as firebase_auth
except ModuleNotFoundError:  # pragma: no cover - optional in local demo setups.
    firebase_admin = None
    firebase_auth = None

# ------------------------------------------------------------
# CORS CONFIGURATION
# ------------------------------------------------------------
raw_origins = os.getenv(
    "ECPAY_ALLOWED_ORIGINS",
    "http://localhost,http://127.0.0.1,http://10.0.2.2",
)
ALLOWED_ORIGINS: List[str] = [
    origin.strip() for origin in raw_origins.split(",") if origin.strip()
]

app = FastAPI(title="ECpay Backend")

# Allows localhost, 127.0.0.1, 10.0.2.2, and local LAN IPs (192.168.x.x, 10.x.x.x)
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.\d+\.\d+|10\.\d+\.\d+\.\d+)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],  # Includes OPTIONS for preflight requests
    allow_headers=["*"],
)

# ------------------------------------------------------------
# UNIFIED ERROR FORMATTER FOR FLUTTER CLIENT
# ------------------------------------------------------------
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Formats Pydantic validation errors so the Flutter app receives:
    {"success": false, "message": "human readable error"}
    """
    normalized_errors = []
    for error in exc.errors():
        normalized_error = {
            "type": error.get("type"),
            "loc": list(error.get("loc", ())),
            "msg": re.sub(r"^Value error,\s*", "", error.get("msg", "Invalid input data.")),
        }
        normalized_errors.append(normalized_error)

    first_error = normalized_errors[0] if normalized_errors else {}

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
        content={
            "success": False,
            "message": first_error.get("msg", "Invalid input data."),
            "detail": normalized_errors,
        },
    )


# In-memory store for demonstration
BANK_ACCOUNT_STORE: Dict[str, Dict[str, Any]] = {}


# ------------------------------------------------------------
# MODELS
# ------------------------------------------------------------
class BankAccountDetails(BaseModel):
    # Changed from 'forbid' to 'ignore' so extra fields don't break validation
    model_config = ConfigDict(extra="ignore")

    account_holder_name: str
    bank_name: str
    account_number: str
    confirm_account_number: str
    ifsc_code: str

    @field_validator("account_holder_name", "bank_name")
    @classmethod
    def validate_required_fields(cls, value: str) -> str:
        cleaned = value.strip()
        if not cleaned:
            raise ValueError("This field is required.")
        return cleaned

    @field_validator("account_number", "confirm_account_number")
    @classmethod
    def validate_account_number_fields(cls, value: str) -> str:
        cleaned = value.strip()
        if not re.fullmatch(r"\d{9,18}", cleaned):
            raise ValueError("Enter a valid 9-18 digit account number.")
        return cleaned

    @field_validator("ifsc_code")
    @classmethod
    def validate_ifsc(cls, value: str) -> str:
        cleaned = value.strip().upper()
        if not re.fullmatch(r"[A-Z]{4}0[A-Z0-9]{6}", cleaned):
            raise ValueError("Enter a valid IFSC code (e.g., SBIN0001234).")
        return cleaned

    @model_validator(mode="after")
    def validate_matching_account_numbers(self):
        if self.account_number != self.confirm_account_number:
            raise ValueError("Account numbers do not match.")
        return self


class BankAccountSummary(BaseModel):
    uid: str
    bank_name: str
    account_holder_name: str
    account_last_four: str
    ifsc_code: str
    verification_status: str = "demo_only"


# ------------------------------------------------------------
# FIREBASE UTILITIES
# ------------------------------------------------------------
def _initialize_firebase() -> bool:
    if firebase_admin is None:
        return False

    apps = getattr(firebase_admin, "_apps", {})
    if not apps:
        try:
            firebase_admin.initialize_app()
        except Exception:
            return False
    return True


# Defined as synchronous def so blocking verify_id_token runs in a worker thread
def get_current_user(
    authorization: Optional[str] = Header(default=None, alias="Authorization"),
) -> dict:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )

    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Authorization header.",
        )

    if not _initialize_firebase():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Firebase authentication is not configured on this backend.",
        )

    try:
        decoded = firebase_auth.verify_id_token(token)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired Firebase token.",
        ) from exc

    return decoded


# ------------------------------------------------------------
# ENDPOINTS
# ------------------------------------------------------------
@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "ECpay backend",
        "firebase_configured": _initialize_firebase(),
        "demo_mode": True,
    }


@app.get("/")
def home():
    return {"app": "ECpay", "message": "ECpay backend is running"}


@app.get("/me")
def get_profile(current_user: dict = Depends(get_current_user)):
    uid = current_user.get("uid") or current_user.get("sub")
    return {
        "uid": uid,
        "email": current_user.get("email"),
        "email_verified": bool(current_user.get("email_verified", False)),
    }


@app.post("/validate-bank-account")
def validate_bank_account(details: BankAccountDetails):
    return {
        "success": True,
        "message": f"Account details verified for {details.bank_name}.",
        "verified": False,
    }


@app.post("/bank-account-summary", response_model=BankAccountSummary)
def save_bank_account_summary(
    details: BankAccountDetails,
    current_user: dict = Depends(get_current_user),
):
    uid = current_user.get("uid") or current_user.get("sub")
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User identity could not be resolved from token.",
        )

    account_num = details.account_number
    last_four = account_num[-4:] if len(account_num) >= 4 else account_num

    summary = BankAccountSummary(
        uid=uid,
        bank_name=details.bank_name,
        account_holder_name=details.account_holder_name,
        account_last_four=last_four,
        ifsc_code=details.ifsc_code,
        verification_status="demo_only",
    )
    BANK_ACCOUNT_STORE[uid] = summary.model_dump()
    return summary


@app.get("/bank-account-summary", response_model=BankAccountSummary)
def read_bank_account_summary(current_user: dict = Depends(get_current_user)):
    uid = current_user.get("uid") or current_user.get("sub")
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User identity could not be resolved from token.",
        )

    summary = BANK_ACCOUNT_STORE.get(uid)
    if not summary:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No bank account summary found for this user.",
        )
    return BankAccountSummary(**summary)


# ------------------------------------------------------------
# RUN SCRIPT DIRECTLY
# ------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    # Listens on all interfaces so mobile emulators/devices can connect
    uvicorn.run(app, host="0.0.0.0", port=8000)