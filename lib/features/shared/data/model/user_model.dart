import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final Timestamp? lastLogin;
  final String? fcmToken;
  final List<String> joinedClasses;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.lastLogin,
    this.fcmToken,
    required this.joinedClasses,
  });

  factory UserModel.fromFireStore(Map<String, dynamic> jsonData) {
    return UserModel(
      uid: jsonData['uid'] ?? '',
      name: jsonData['name'],
      email: jsonData['email'],
      photoUrl: jsonData['photoUrl'],
      lastLogin: jsonData['lastLogin'],
      fcmToken: jsonData['fcmToken'],
      joinedClasses: List<String>.from(jsonData['joinedClasses'] ?? []),
    );
  }

  // ✅ Convert UserModel to Firestore Map
  Map<String, dynamic> toFireStore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastLogin': lastLogin ?? FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
      'joinedClasses': joinedClasses,
    };
  }
}
