import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/classroom/data/models/class_room_model.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

class ClassRoomController extends GetxController {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<ClassRoomModel> _myClassList = [];
  List<ClassRoomModel> get myClassList => _myClassList;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> getMyClasses(String uid) async {
    bool isSuccess = false;
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!userDoc.exists) {
        _isLoading = false;
        update();
        _errorMessage = 'User Not Found';
        return false;
      }
      final modelUser = UserModel.fromFireStore(userDoc.data()!);
      AuthController.user = modelUser;
      print(modelUser);
      _currentUser = modelUser;
      print(modelUser.joinedClasses);
      final joinedClassesDocIds = modelUser.joinedClasses;
      if (joinedClassesDocIds.isEmpty) {
        debugPrint("Your Joined Class List is Empty");
        _myClassList = [];
        isSuccess = true;
      } else {
        debugPrint("Your Joined class list : $joinedClassesDocIds");
        final classSnapshot = await FirebaseFirestore.instance
            .collection(Collectons.classes)
            .where(FieldPath.documentId, whereIn: joinedClassesDocIds)
            .get();
        final classList = List<ClassRoomModel>.from(
          classSnapshot.docs.map((e) => ClassRoomModel.fromFireStore(e.data(),e.id)),
        );
        debugPrint("Your joined class list:$classList");
        _myClassList = classList;
      }
      _isLoading =false;
      isSuccess = true;
    } catch (e) {
      _errorMessage = "Error fetching your classes";
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> joinClass(String code, String uid) async {
    bool isSuccess = false;
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(code)
          .get();
      if (!classDoc.exists) {
        _errorMessage = 'ClassRoom Not Found';
        isSuccess = false;
      } else {
        _errorMessage = null;
        await FirebaseFirestore.instance.collection('classes').doc(code).update(
          {
            'students': FieldValue.arrayUnion([uid]),
          },
        );
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'joinedClasses': FieldValue.arrayUnion([code]),
        });
        AuthController.classDocId = code;
        isSuccess = true;
      }
    } catch (e) {
      _errorMessage = "Joining on a new ClassRoom Failed";
      isSuccess = false;
    }
    _isLoading = false;
    return isSuccess;
  }

  Future<bool> createClass(ClassRoomModel classModel, String uid) async {
    bool isSuccess = false;
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      final classCode = _generateCode();
      await FirebaseFirestore.instance.collection('classes').doc(classCode).set(
        {
          ...classModel.toFireStore(),
          'students': FieldValue.arrayUnion([uid]),
          'code': classCode,
          'admins':FieldValue.arrayUnion([uid]),
        },
      );
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'joinedClasses': FieldValue.arrayUnion([classCode]),
      }, SetOptions(merge: true));

      AuthController.classDocId = classCode;
      isSuccess = true;
    } catch (e) {
      _errorMessage = "Creating on a new ClassRoom Failed";
      isSuccess = false;
    }
    _isLoading = false;
    return isSuccess;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (i) => chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length],
    ).join();
  }


  Future<void> refreshMyClasses() async {
    if (AuthController.user != null) {
      await getMyClasses(AuthController.user!.uid);
    }
  }
}
