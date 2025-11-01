import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signup_screen.dart';
import 'package:universityclassroommanagement/features/home/presentation/screens/home_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/screens/bottom_nav_holder.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static const name = '/signin-screen';

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Cancelled by user

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      final token = await FirebaseMessaging.instance.getToken();



      if (user != null) {
        // Save user data to Firestore (if not exists)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'fcmToken': token,
        }, SetOptions(merge: true));

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully!')),
        );

        // Go to HomeScreen
        Navigator.pushReplacementNamed(context, BottomNavHolder.name);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 40),
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              // icon: Image.asset(
              //   'assets/google.png',
              //   height: 24,
              // ),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
            ),
            FilledButton(onPressed: (){
              Navigator.pushNamed(context, SignupScreen.name);
            }, child: Text("SignUp"))
          ],
        ),
      ),
    );
  }
}
