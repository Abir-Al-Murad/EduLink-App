import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:universityclassroommanagement/app/assets_path.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/core/services/firebase_messaging.dart';
import 'package:universityclassroommanagement/core/services/local_db_helper.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signin_screen.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signup_screen.dart';
import 'package:universityclassroommanagement/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/screens/bottom_nav_holder.dart';

import 'features/auth/presentaion/widgets/hero_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> moveToNext()async{
    FirebaseMessagingService service = FirebaseMessagingService();
    final NotificationSettings settings = await service.settings();

    LocalDbHelper dbInstance = LocalDbHelper.getInstance();
    AuthController.user = await dbInstance.getUser();
    print({"Splash screen: ${AuthController.user!.name}"});

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted permission");
    } else {
      print("❌ User declined or has not accepted permission");
    }

    service.listenForegroundMessages();
   await Future.delayed(Duration(seconds: 2));
   await checkLoginStatus();
   final messaging = FirebaseMessaging.instance;
   await messaging.requestPermission();
  }

  Future<void> checkLoginStatus()async{
    final user = FirebaseAuth.instance.currentUser;
    if(user !=null){
      Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate)=>false);
    }else{
      Navigator.pushNamedAndRemoveUntil(context, SigninScreen.name, (predicate)=>false);

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
