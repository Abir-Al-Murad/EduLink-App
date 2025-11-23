import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentsModel {
  final String studentId;
  final String fileUrl;
  final String fileName;
  final Timestamp uploadedAt;

  AttachmentsModel({
    required this.fileUrl,
    required this.studentId,
    required this.uploadedAt,
    required this.fileName,
  });

  AttachmentsModel copyWith({
    String? studentId,
    String? fileUrl,
    String? fileName,
    Timestamp? uploadedAt,
  }) {
    return AttachmentsModel(
      studentId: studentId ?? this.studentId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  factory AttachmentsModel.fromMap(Map<String, dynamic> map) {
    return AttachmentsModel(
      fileUrl: map['fileUrl'],
      studentId: map['studentId'],
      fileName: map['fileName']??"File",
      uploadedAt: (map['uploadedAt'] as Timestamp),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt,
      'fileName':fileName,
    };
  }
}
