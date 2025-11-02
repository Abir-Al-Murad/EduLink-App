import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String? fcmToken;
  final List<String>? joinedClasses;
  final Timestamp? lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.fcmToken,
    this.joinedClasses,
    this.lastLogin,
  });


  factory UserModel.fromFireStore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      fcmToken: data['fcmToken'],
      joinedClasses: List<String>.from(data['joinedClasses'] ?? []),
      lastLogin: data['lastLogin'],
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
      'lastLogin': lastLogin ?? Timestamp.now(),
    };
  }
}
