
import 'package:flutter/cupertino.dart';
import 'package:universityclassroommanagement/features/classroom/data/models/class_room_model.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';

class AuthController{
  static String? classDocId;
  static bool isAdmin = false;
  static UserModel? user;
  static ClassRoomModel? currentClassRoom;
  //classDocId save na kore full model save kora
  // usermodel save kora


  static void authClear(){
    classDocId = null;
    isAdmin = false;
    debugPrint("All Auth Data Cleared");
  }

}