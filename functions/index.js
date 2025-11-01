// ✅ Firebase Functions v2 syntax
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// Trigger when a new task is added in Firestore
exports.sendNotificationOnNewTask = onDocumentCreated("tasks/{taskId}", async (event) => {
  const newTask = event.data.data();


const message = {
  notification: {
    title: `${newTask.title || "Untitled Task"}`,
    body: `${newTask.description || "A new task has been added!"}`,
  },
  topic: "allUsers",
};




  try {
    await getMessaging().send(message);
    console.log("✅ Notification sent to all users!");
  } catch (error) {
    console.error("❌ Error sending notification:", error);
  }
});
