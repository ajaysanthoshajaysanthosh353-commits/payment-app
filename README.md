# payment_app

A Flutter demo payment application.

## Local bank validation demo

The bank-link form sends account details to a local FastAPI endpoint for
format validation only. It does not contact a bank or verify account ownership.
Do not use real banking details with this demo.

From the repository root, install the backend packages and start the service:

```powershell
py -m pip install fastapi uvicorn
py -m uvicorn lib.backend.bank_account:app --host 0.0.0.0 --port 8000
```

The Android emulator uses `http://10.0.2.2:8000` by default. For a physical
device, pass the computer's reachable address when starting Flutter:

```powershell
flutter run --dart-define=BANK_API_BASE_URL=http://<computer-ip>:8000
```

Use an HTTPS backend for iOS devices and production builds.

The Python backend also exposes:

- `GET /health` for startup checks
- `GET /me` for Firebase-authenticated profile reads
- `POST /validate-bank-account` for demo-only format validation
- `POST /bank-account-summary` for authenticated bank summary storage

The service never stores full account numbers or bank passwords, and it does not
claim ownership verification unless a real bank or payments-provider confirms it.
