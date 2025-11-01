import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/controller_binder.dart';
import 'package:universityclassroommanagement/app/routes.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/screens/bottom_nav_holder.dart';
import 'package:universityclassroommanagement/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      onGenerateRoute: onGenerateRoute,

      home:SplashScreen(),
    );
  }
}
