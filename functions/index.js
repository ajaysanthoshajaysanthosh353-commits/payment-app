/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const bcrypt = require("bcryptjs");

initializeApp();

const db = getFirestore();

// ============================================================
// VERIFY ECPAY PAYMENT PIN
// ============================================================

exports.verifyPaymentPin = onCall(
  {
    enforceAppCheck: true,
  },
  async (request) => {
    // Require a signed-in Firebase user.
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Please log in before making a payment."
      );
    }

    const pin = request.data?.pin;

    // Validate the PIN format on the server too.
    if (
      typeof pin !== "string" ||
      !/^[0-9]{4}$/.test(pin)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "A valid four-digit PIN is required."
      );
    }

    const uid = request.auth.uid;

    // Read only the signed-in user's document.
    const userRef = db.collection("users").doc(uid);
    const userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      throw new HttpsError(
        "not-found",
        "User profile was not found."
      );
    }

    const userData = userSnapshot.data();
    const pinHash = userData.pinHash;

    if (
      typeof pinHash !== "string" ||
      !pinHash.startsWith("$2")
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Payment PIN has not been configured securely."
      );
    }

    // Compare the entered PIN with its stored hash.
    const matches = await bcrypt.compare(pin, pinHash);

    if (!matches) {
      // Do not reveal the stored PIN or hash.
      return {
        success: false,
      };
    }

    return {
      success: true,
    };
  }
);