import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:universityclassroommanagement/core/services/notification_sevice.dart';

class FirebaseMessagingService{
  FirebaseMessaging messaging = FirebaseMessaging.instance;



  Future<NotificationSettings> settings()async{
    return await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title} - ${message.notification?.body}");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification !=null && android !=null){
        NotificationService service = NotificationService();
        service.showNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
        );
      }
    });
  }


}