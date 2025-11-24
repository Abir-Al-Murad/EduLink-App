import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/connectivity_service.dart';
import 'package:EduLink/core/services/notification_sevice.dart';
import 'package:EduLink/core/services/update_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/app/assets_path.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/firebase_messaging.dart';
import 'package:EduLink/features/auth/presentaion/screens/signin_screen.dart';
import 'package:EduLink/features/classroom/presentation/screens/my_classrooms_screen.dart';

import 'features/auth/presentaion/widgets/hero_logo.dart';
import 'features/my class/data/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> moveToNext()async{

    NotificationService _notificationService = NotificationService();
    _notificationService.getPendingNotifications();
    FirebaseMessagingService service = FirebaseMessagingService();
    final NotificationSettings settings = await service.settings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted permission");
    } else {
      print("❌ User declined or has not accepted permission");
    }

    service.listenForegroundMessages();
    UpdateChecker checker =UpdateChecker(context);
    await checker.checkForUpdate();
   await checkLoginStatus();
   final messaging = FirebaseMessaging.instance;
   await messaging.requestPermission();
  }

  Future<void> checkLoginStatus()async{

    if(!ConnectivityService().isOffline.value){
      try {
        final user = FirebaseAuth.instance.currentUser;

        if(user !=null){
          final currentUser = await FirebaseFirestore.instance.collection(Collectons.users).doc(user.uid).get();
           UserModel userModel = UserModel.fromFireStore(currentUser.data()!);
          await Get.find<AuthController>().saveUserData(userModel);
          Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate)=>false);
        }else{
          Navigator.pushNamedAndRemoveUntil(context, SigninScreen.name, (predicate)=>false);

        }
      }catch (e) {
        debugPrint("Something error on checking loginStatus");
      }
    }else{
      try {
        bool isUserLoggedIn = await Get.find<AuthController>().isUserAlreadyLoggedIn();

        if (isUserLoggedIn) {
          bool dataLoaded = await Get.find<AuthController>().loadUserData();

          if (dataLoaded && AuthController.user != null) {
            Navigator.pushNamedAndRemoveUntil(
                context,
                MyClassrooms.name,
                    (predicate) => false
            );
          } else {
            debugPrint("⚠️ User data corrupted, redirecting to sign in");
            Navigator.pushNamedAndRemoveUntil(
                context,
                SigninScreen.name,
                    (predicate) => false
            );
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context,
              SigninScreen.name,
                  (predicate) => false
          );
        }
      } catch (e) {
        debugPrint("❌ Something error on checking loginStatus (Offline): $e");
        Navigator.pushNamedAndRemoveUntil(
            context,
            SigninScreen.name,
                (predicate) => false
        );
      }
    }


  }

  @override
  void initState() {
    moveToNext();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          HeroLogo(tag: 'logo', imagePath: AssetsPath.eduLinkLogo,),
            CircularProgressIndicator(),
          ],
        ),
      )
    );
  }
}
