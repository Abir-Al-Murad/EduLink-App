import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/core/services/local_db_helper.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';

class SigninAndSignupController extends GetxController {
  bool _isLoading = false;
  bool  get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool>signInWithGoogle()async{
    bool isSuccess = false;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    _isLoading = true;
    update();
    try{
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if(googleUser == null){
        isSuccess = false;
      }else{
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await auth.signInWithCredential(credential);
        final user = userCredential.user;
        final token = await FirebaseMessaging.instance.getToken();
        if(user !=null){
          Map<String,dynamic>userMap = {
            'name':user.displayName,
            'photoUrl':user.photoURL,
            'uid':user.uid,
            'email':user.email,
            'fcmToken':token,
            'lastLogin':Timestamp.now(),
          };
          await FirebaseFirestore.instance
              .collection(Collectons.users)
              .doc(user.uid)
              .set(userMap, SetOptions(merge: true));
          LocalDbHelper instance = LocalDbHelper.getInstance();
          await instance.addUser(model: UserModel.fromFireStore(userMap));
          AuthController.user = UserModel.fromFireStore(userMap);

        }


        isSuccess = true;
      }

    }catch(e){
      isSuccess = false;
      _errorMessage = "Google Sign-In Error";
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> signUpWithGoogle() async {
    bool isSuccess = false;
    _isLoading = true;
    update();

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled sign in
        isSuccess = false;
      } else {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        final userCredential = await auth.signInWithCredential(credential);
        final user = userCredential.user;
        final token = await FirebaseMessaging.instance.getToken();

        if (user != null) {
          final userRef = firestore.collection(Collectons.users).doc(user.uid);
          final doc = await userRef.get();
          Map<String,dynamic>userMap = {
            'name':user.displayName,
            'photoUrl':user.photoURL,
            'uid':user.uid,
            'email':user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'fcmToken':token,
            'lastLogin':FieldValue.serverTimestamp(),
          };
          if (!doc.exists) {
            // 🆕 New user → create document
            await userRef.set(userMap);
          } else {
            // 👤 Existing user → update login info
            await userRef.update({
              'lastLogin': FieldValue.serverTimestamp(),
              'fcmToken': token,
            });
          }
          LocalDbHelper instance = LocalDbHelper.getInstance();
          instance.addUser(model: UserModel.fromFireStore(userMap));
          AuthController.user = UserModel.fromFireStore(userMap);
          isSuccess = true;
        }
      }
    } catch (e) {
      _errorMessage = "Google Sign-Up Error: ${e.toString()}";
      isSuccess = false;
    }

    _isLoading = false;
    update();
    return isSuccess;
  }






}