import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String title;
  final String description;
  final Timestamp deadline;
  final Timestamp? assignedDate;
  final List<String> completedBy;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.assignedDate,
    this.completedBy = const [],
  });

  factory TaskModel.fromFireStore(Map<String, dynamic> jsonData, String id) {
    return TaskModel(
      id: id,
      title: jsonData['title'] ?? '',
      description: jsonData['description'] ?? '',
      deadline: jsonData['deadline'],
      assignedDate: jsonData['assignedDate'],
      completedBy: jsonData['completedBy'] != null
          ? List<String>.from(jsonData['completedBy'])
          : [],
    );
  }

  Map<String, dynamic> toFireStore(String title, String description, Timestamp deadline) {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'assignedDate': Timestamp.now(),
      'completedBy': completedBy,
    };
  }
}
