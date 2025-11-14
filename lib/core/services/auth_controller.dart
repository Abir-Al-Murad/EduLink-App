
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/classroom/data/models/class_room_model.dart';
import '../../features/profile/data/models/user_model.dart';

class AuthController extends GetxController{
  static String? classDocId;
  static bool isAdmin = false;
  static UserModel? user;
  static ClassRoomModel? currentClassRoom;
  static String? userId;
  //classDocId save na kore full model save kora
  // usermodel save kora


  static void authClear(){
    classDocId = null;
    isAdmin = false;
    debugPrint("All Auth Data Cleared");
  }

  final String _userToken = 'userModel';
  final String _classToken = 'classModel';
  final String _idToken = 'userId';
  Future<void>saveUserData(UserModel model)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_userToken, jsonEncode(model.toFireStore()));
    sharedPreferences.setString(_idToken, model.uid);

    debugPrint('''
    --------------------------------------
    User Data Saved to Local - 
    UserData - ${jsonEncode(model.toFireStore())}
    UserID - ${model.uid}
    --------------------------------------
    ''');

  }
  Future<void>saveClassData(ClassRoomModel model)async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_classToken, jsonEncode(model.toFireStore()));
  }

  Future<bool> loadUserData() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      // Check if user data exists
      String? userDataString = sharedPreferences.getString(_userToken);
      String? userIdString = sharedPreferences.getString(_idToken);

      if (userDataString == null || userIdString == null) {
        debugPrint("⚠️ No user data found in SharedPreferences");
        return false;
      }

      // Parse user data
      Map<String, dynamic> userData = jsonDecode(userDataString);
      user = UserModel.fromFireStore(userData);
      userId = userIdString;

      debugPrint('''
    --------------------------------------
    ✅ User Data fetched from Local - 
    UserName - ${user!.name}
    UserEmail - ${user!.email}
    UserID - $userId
    JoinedClasses - ${user!.joinedClasses.length}
    --------------------------------------
    ''');

      return true;
    } catch (e) {
      debugPrint("❌ Error loading user data: $e");
      // Clear corrupted data
      await clearUserData();
      return false;
    }
  }


  Future<bool> isUserAlreadyLoggedIn()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? id = sharedPreferences.getString(_idToken);
    debugPrint('''
    --------------------------------------
    User ID fetching from Local - 
    UserID - ${id}
    --------------------------------------
    ''');
    if(id !=null){
      return true;
    }else{
     return false;
    }
  }

  Future<void> clearUserData()async{
    SharedPreferences sharedPreferences =await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }




}