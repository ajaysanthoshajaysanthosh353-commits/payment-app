import unittest

from fastapi.testclient import TestClient

from lib.backend.bank_account import app


class BankAccountApiTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health_check(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(payload["status"], "ok")

    def test_validate_bank_account_accepts_valid_details(self):
        payload = {
            "account_holder_name": "Asha Kumar",
            "bank_name": "State Bank of India",
            "account_number": "123456789",
            "confirm_account_number": "123456789",
            "ifsc_code": "SBIN0001234",
        }

        response = self.client.post("/validate-bank-account", json=payload)
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()["success"])

    def test_validate_bank_account_rejects_mismatching_numbers(self):
        payload = {
            "account_holder_name": "Asha Kumar",
            "bank_name": "HDFC Bank",
            "account_number": "123456789",
            "confirm_account_number": "987654321",
            "ifsc_code": "HDFC0001234",
        }

        response = self.client.post("/validate-bank-account", json=payload)
        self.assertEqual(response.status_code, 422)
        error = response.json()
        self.assertFalse(error["success"])
        self.assertEqual(error["message"], "Account numbers do not match.")

    def test_validate_bank_account_rejects_invalid_ifsc(self):
        payload = {
            "account_holder_name": "Asha Kumar",
            "bank_name": "ICICI Bank",
            "account_number": "123456789",
            "confirm_account_number": "123456789",
            "ifsc_code": "BADIFSC",
        }

        response = self.client.post("/validate-bank-account", json=payload)
        self.assertEqual(response.status_code, 422)
        error = response.json()
        self.assertFalse(error["success"])
        self.assertEqual(
            error["message"],
            "Enter a valid IFSC code (e.g., SBIN0001234).",
        )

    def test_profile_requires_bearer_token(self):
        response = self.client.get("/me")
        self.assertEqual(response.status_code, 401)


if __name__ == "__main__":
    unittest.main()
