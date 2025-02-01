const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Create User Function
exports.createUser = functions.https.onCall(async (data, context) => {
    const { email, password, role, createdBy } = data;

    // Verify if request is from an authorized user (Admin or Manager)
    const creatorDoc = await admin.firestore().collection("users").doc(createdBy).get();
    
    if (!creatorDoc.exists) {
        throw new functions.https.HttpsError("not-found", "User not found.");
    }

    const creatorRole = creatorDoc.data().role;
    
    if (creatorRole !== "admin" && creatorRole !== "manager") {
        throw new functions.https.HttpsError("permission-denied", "Only admins and managers can create users.");
    }

    // Ensure Managers can only create Employees
    if (creatorRole === "manager" && role !== "employee") {
        throw new functions.https.HttpsError("permission-denied", "Managers can only create employees.");
    }

    try {
        // Create Firebase Authentication User
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
        });

        // Save user info in Firestore
        await admin.firestore().collection("users").doc(userRecord.uid).set({
            email: email,
            role: role,
            createdBy: createdBy,
        });

        return { uid: userRecord.uid };
    } catch (error) {
        throw new functions.https.HttpsError("internal", error.message);
    }
});
