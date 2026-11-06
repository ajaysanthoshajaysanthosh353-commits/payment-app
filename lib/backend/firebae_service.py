import os
from typing import Any, Dict, Optional

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ModuleNotFoundError:  # pragma: no cover - optional dependency for local demo builds.
    firebase_admin = None
    credentials = None
    firestore = None

# Fallback store so demo mode actually retains data
DEMO_STORE: Dict[str, Dict[str, Any]] = {}

# Cached Firestore client instance
_db_client = None


def initialize_firebase() -> Optional[Any]:
    """
    Safely initializes Firebase Admin SDK without crashing if credentials
    are missing or invalid, returning a Firestore client or None.
    """
    global _db_client

    if firebase_admin is None or firestore is None:
        return None

    if _db_client is not None:
        return _db_client

    try:
        if not firebase_admin._apps:
            service_account_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or os.getenv(
                "FIREBASE_SERVICE_ACCOUNT_PATH"
            )

            if service_account_path and os.path.exists(service_account_path):
                cred = credentials.Certificate(service_account_path)
                firebase_admin.initialize_app(cred)
            else:
                # Attempts default credentials / emulator setup
                firebase_admin.initialize_app()

        _db_client = firestore.client()
        return _db_client
    except Exception as error:
        # Graceful fallback: log and proceed in demo mode
        print(f"[Firebase Init Warning] Could not connect to Firestore: {error}")
        return None


def save_bank_summary(
    user_id: str,
    bank_name: str,
    account_holder_name: str,
    last_four_digits: str,
    ifsc_code: str,
) -> Dict[str, Any]:
    """
    Saves the user's bank metadata to Firestore, or falls back to
    an in-memory store in demo mode.
    """
    clean_user_id = (user_id or "").strip()
    if not clean_user_id:
        return {
            "success": False,
            "message": "User ID cannot be empty.",
            "demoMode": False,
        }

    clean_last_four = (last_four_digits or "").strip()
    if len(clean_last_four) > 4:
        clean_last_four = clean_last_four[-4:]

    # Canonical document payload
    bank_data = {
        "bankSetupDemoComplete": True,
        "bankName": (bank_name or "").strip(),
        "accountHolderName": (account_holder_name or "").strip(),
        "bankAccountLastFour": clean_last_four,
        "ifscCode": (ifsc_code or "").strip().upper(),
        "bankVerificationStatus": "demo_only",
    }

    db = initialize_firebase()

    # DEMO MODE: Store in memory so it's not discarded
    if db is None:
        DEMO_STORE[clean_user_id] = {
            **bank_data,
            "demoOnly": True,
        }
        return {
            "success": True,
            "message": "Bank account summary stored in demo mode.",
            "demoMode": True,
            "data": DEMO_STORE[clean_user_id],
        }

    # FIRESTORE PRODUCTION / EMULATOR WRITE
    try:
        # Include server timestamp consistent with Flutter's FieldValue.serverTimestamp()
        firestore_payload = {
            **bank_data,
            "bankLinkedAt": firestore.SERVER_TIMESTAMP,
        }

        db.collection("users").document(clean_user_id).set(
            firestore_payload,
            merge=True,
        )

        return {
            "success": True,
            "message": "Bank account summary saved to Firestore.",
            "demoMode": False,
        }
    except Exception as error:
        # Catch network or permission errors
        return {
            "success": False,
            "message": f"Failed to save to Firestore: {error}",
            "demoMode": False,
        }