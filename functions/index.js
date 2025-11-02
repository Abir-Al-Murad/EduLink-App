const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

/**
 * ✅ Send notification when a new Task is added to a Class
 * Trigger: /classes/{classId}/tasks/{taskId}
 */
exports.sendNotificationOnNewTask = onDocumentCreated("classes/{classId}/tasks/{taskId}", async (event) => {
  const { classId, taskId } = event.params;
  const newTask = event.data.data();

  console.log(`📚 New task in class: ${classId}`, newTask);

  try {
    // 1️⃣ Fetch the class to get student list
    const classDoc = await db.collection("classes").doc(classId).get();
    if (!classDoc.exists) {
      console.error("❌ Class not found:", classId);
      return;
    }

    const classData = classDoc.data();
    const studentIds = classData.students || [];

    // 2️⃣ Get FCM tokens for each student
    const tokens = [];
    const userDocs = await db.collection("users")
      .where("uid", "in", studentIds)
      .get();

    userDocs.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken) tokens.push(user.fcmToken);
    });

    if (tokens.length === 0) {
      console.log("⚠️ No tokens found for this class");
      return;
    }

    // 3️⃣ Build notification message
    const message = {
      notification: {
        title: `📝 ${newTask.title || "New Task Assigned"}`,
        body: `${newTask.description || "Check your class for details!"}`,
      },
      data: {
        type: "new_task",
        classId,
        taskId,
      },
      tokens, // send to multiple users
      android: {
        notification: {
          color: "#1a237e",
          sound: "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // 4️⃣ Send notification
    const response = await getMessaging().sendEachForMulticast(message);
    console.log(`✅ Notification sent to ${response.successCount}/${tokens.length} users`);
  } catch (error) {
    console.error("❌ Error sending task notification:", error);
  }
});


/**
 * ✅ Send notification when a new Announcement is added to a Class
 * Trigger: /classes/{classId}/announcements/{announcementId}
 */
exports.sendNotificationOnNewAnnouncement = onDocumentCreated(
  "classes/{classId}/notices/{noticeId}",
  async (event) => {
    const { classId, noticeId } = event.params;
    const notice = event.data.data();

    console.log(`📢 New notice in class: ${classId}`, notice);

    try {
      // 1️⃣ Get class info
      const classDoc = await db.collection("classes").doc(classId).get();
      if (!classDoc.exists) {
        console.error("❌ Class not found:", classId);
        return;
      }

      const classData = classDoc.data();
      const studentIds = classData.students || [];

      // 2️⃣ Get FCM tokens from user documents
      const tokens = [];
      const userSnapshot = await db
        .collection("users")
        .where("uid", "in", studentIds)
        .get();

      userSnapshot.forEach((doc) => {
        const user = doc.data();
        if (user.fcmToken) tokens.push(user.fcmToken);
      });

      if (tokens.length === 0) {
        console.log("⚠️ No tokens found for this class");
        return;
      }

      // 3️⃣ Prepare notification message
      const message = {
        notification: {
          title: `📢 ${notice.title || "New Announcement"}`,
          body: `${notice.description || "Check your class for details!"}`,
        },
        data: {
          type: "new_announcement",
          classId,
          noticeId,
        },
        tokens,
        android: {
          notification: {
            color: "#1a237e",
            sound: "default",
            priority: "high",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      // 4️⃣ Send push notifications
      const response = await getMessaging().sendEachForMulticast(message);
      console.log(
        `✅ Announcement sent to ${response.successCount}/${tokens.length} users`
      );
    } catch (error) {
      console.error("❌ Error sending announcement notification:", error);
    }
  }
);
