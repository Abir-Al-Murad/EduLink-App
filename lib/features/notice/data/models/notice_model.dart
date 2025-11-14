import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String title;
  final String description;
  final Timestamp createdAt;
  final String? id;

  NoticeModel(
    {this.id,
      required this.title,
    required this.description,
    required this.createdAt,
  });

  factory NoticeModel.fromFireStore(Map<String, dynamic> jsonData,String id) {
    return NoticeModel(
      id: id,
      title: jsonData['title'],
      description: jsonData['description'],
      createdAt: jsonData['createdAt'],
    );
  }
  factory NoticeModel.fromMap(Map<String, dynamic> jsonData) {
    return NoticeModel(
      id: jsonData['notice_id'],
      title: jsonData['title'],
      description: jsonData['description'],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(
          jsonData['createdAt'] as int
      ),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {'title': title, 'description': description, 'createdAt': createdAt};
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
