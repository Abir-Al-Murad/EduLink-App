import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:EduLink/app/controller_binder.dart';
import 'package:EduLink/app/routes.dart';
import 'package:EduLink/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinding(),
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        hintColor: Colors.grey,
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.royalThemeColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          labelStyle: const TextStyle(fontSize: 14),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.themeColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          )

        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,

        )
      ),
      home:SplashScreen(),
    );
  }
}
