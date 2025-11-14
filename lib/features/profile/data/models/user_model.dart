import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String? fcmToken;
  final List<String> joinedClasses;
  final Timestamp? lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.fcmToken,
    List<String>? joinedClasses,
    this.lastLogin,
  }):joinedClasses = joinedClasses??[];


  factory UserModel.fromFireStore(Map<String, dynamic> data) {
    dynamic lastLoginData = data['lastLogin'];
    Timestamp? lastLogin;

    if (lastLoginData is Timestamp) {
      lastLogin = lastLoginData;
    } else if (lastLoginData is int) {
      lastLogin = Timestamp.fromMillisecondsSinceEpoch(lastLoginData);
    }
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      fcmToken: data['fcmToken'],
      joinedClasses: List<String>.from(data['joinedClasses'] ?? []),
      lastLogin: lastLogin,
    );
  }


  Map<String, dynamic> toFireStore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'joinedClasses': joinedClasses,
      'lastLogin': (lastLogin ?? Timestamp.now()).millisecondsSinceEpoch,
    };
  }
}
