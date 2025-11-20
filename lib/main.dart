
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:timezone/data/latest.dart';
import 'package:EduLink/core/services/connectivity_service.dart';

import 'package:EduLink/core/services/notification_sevice.dart';
import 'package:EduLink/firebase_options.dart';

import 'app/app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  initializeTimeZones();
  final notificationService = NotificationService();
  await notificationService.initNotification();
  await ConnectivityService().initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  subscribeUserToAllUsersTopic();
  runApp(DevicePreview(
    enabled:false,
    builder: (context) {
      return const MyApp();
    }
  ));
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.notification?.title}");
}

void subscribeUserToAllUsersTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic("allUsers");
  print("✅ Device subscribed to allUsers topic");
}
