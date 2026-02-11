import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

export const deleteUserAccount = onCall(
  {region: "europe-west1"},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be logged in."
      );
    }

    const uid = request.auth.uid;
    const db = admin.firestore();

    try {
      console.log(
        `Deleting account for UID: ${uid}`
      );

      await db
        .collection("deleted_users")
        .doc(uid)
        .set({
          deletedAt:
            admin.firestore.FieldValue.serverTimestamp(),
        });

      const userDocRef =
        db.collection("users").doc(uid);

      await db.recursiveDelete(userDocRef);


      await admin.auth().deleteUser(uid);

      console.log(
        `Successfully deleted UID: ${uid}`
      );

      return {success: true};
    } catch (error) {
      console.error(
        "Account deletion failed:",
        error
      );

      throw new HttpsError(
        "internal",
        "Account deletion failed."
      );
    }
  }
);
