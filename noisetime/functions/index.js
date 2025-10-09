/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging"); // Import messaging module

initializeApp();

exports.onNoiseSampleCreate = onDocumentCreated("noise_samples/{sampleId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }
    const noiseSample = snapshot.data();

    const groupId = noiseSample.group_id;
    const userId = noiseSample.user_id;
    
    if (!groupId || !userId) {
        console.log("Missing groupId or userId. Skipping.");
        return;
    }

    const firestore = getFirestore();
    const groupDoc = await firestore.collection('groups').doc(groupId).get();

    if (!groupDoc.exists) {
        console.log(`Group with ID ${groupId} not found. Skipping.`);
        return;
    }

    const groupData = groupDoc.data();
    const noiseThreshold = groupData.noise_threshold || 80; // Use threshold from group or default to 80dB

    if (noiseSample.decibel > noiseThreshold) {
        console.log(`Noise level ${noiseSample.decibel}dB exceeded threshold of ${noiseThreshold}dB.`);
        
        // Fetch user's FCM token
        const userDoc = await firestore.collection('users').doc(userId).get();
        if (!userDoc.exists) {
            console.log(`User with ID ${userId} not found. Cannot send notification.`);
            return;
        }

        const fcmToken = userDoc.data().fcm_token;
        if (!fcmToken) {
            console.log(`User ${userId} does not have an FCM token. Cannot send notification.`);
            return;
        }

        // Construct FCM message
        const message = {
            notification: {
                title: 'Noise Alert!',
                body: `Your current noise level is ${noiseSample.decibel.toFixed(1)}dB, which is above the group threshold!`,
            },
            token: fcmToken,
        };

        // Send the message
        try {
            console.log(`Sending notification to user ${userId}`);
            const response = await getMessaging().send(message);
            console.log('Successfully sent message:', response);
        } catch (error) {
            console.log('Error sending message:', error);
        }
    }

    return null;
});
