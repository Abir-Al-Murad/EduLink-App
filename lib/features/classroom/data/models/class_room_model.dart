import 'package:cloud_firestore/cloud_firestore.dart';

class ClassRoomModel {
  final String? id;
  final String name;
  final String subject;
  final String createdBy;
  final Timestamp createdAt;
  final List<String> students;
  final List<String> admins;

  ClassRoomModel({this.id,
    required this.name,
    required this.subject,
    required this.createdBy,
    required this.createdAt,
    required this.students,
    required this.admins,
  });

  factory ClassRoomModel.fromFireStore(Map<String, dynamic> jsonData,String id) {
    return ClassRoomModel(
      id:id,
      name: jsonData['name'] ?? '',
      subject: jsonData['subject'] ?? '',
      createdBy: jsonData['createdBy'] ?? '',
      createdAt: jsonData['createdAt'] ?? Timestamp.now(),
      students: List<String>.from(jsonData['students'] ?? []),
      admins: List<String>.from(jsonData['admins'] ?? []),
    );
  }


  Map<String, dynamic> toFireStore() {
    return {
      'name': name,
      'subject': subject,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'students': students,
    };
  }
}
