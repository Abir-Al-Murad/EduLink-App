import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentsModel {
  final String studentId;
  final String fileUrl;
  final Timestamp uploadedAt;
  AttachmentsModel({
    required this.fileUrl,
    required this.studentId,
    required this.uploadedAt,
  });

  factory AttachmentsModel.fromMap(Map<String, dynamic> map) {
    return AttachmentsModel(
      fileUrl: map['fileUrl'],
      studentId: map['studentId'],
      uploadedAt: (map['uploadedAt'] as Timestamp),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt,
    };
  }
}
