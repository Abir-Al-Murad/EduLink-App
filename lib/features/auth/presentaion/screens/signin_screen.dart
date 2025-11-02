import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universityclassroommanagement/app/assets_path.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/controllers/signin_and_signup_controller.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signup_screen.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/widgets/eleveted_button_with_logo.dart';
import 'package:universityclassroommanagement/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/centered_circular_progress.dart';

import '../widgets/hero_logo.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static const name = '/signin-screen';

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final SigninAndSignupController _signinAndSignupController = Get.find<SigninAndSignupController>();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GetBuilder<SigninAndSignupController>(
                builder: (controller) {
                  return Column(
                    children: [
                      const SizedBox(height: 120),
                      HeroLogo(tag: 'logo', imagePath: AssetsPath.eduLinkLogo),
                      const Text(
                        'Sign in to manage your classrooms',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // ✅ Google Sign In button
                      ElelvetedButtonWithLogo(
                        onTap: _onTapSignIn,
                        titleText: 'Continue with Google',
                        image: AssetsPath.googleLogo,
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1,
                        height: 20,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _onTapSignUp,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            GetBuilder<SigninAndSignupController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }




  Future<void> _onTapSignIn()async{
    bool isSuccess =await _signinAndSignupController.signInWithGoogle();
    if(isSuccess){
      Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate)=>false);
    }else{
      ShowSnackBarMessage(context, _signinAndSignupController.errorMessage??"Something went wrong");
    }
  }
  Future<void> _onTapSignUp()async{
    bool isSuccess =await _signinAndSignupController.signUpWithGoogle();
    if(isSuccess){
      Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate)=>false);
    }else{
      ShowSnackBarMessage(context, _signinAndSignupController.errorMessage??"Something went wrong");
    }
  }

}


