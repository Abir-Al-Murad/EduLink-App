import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universityclassroommanagement/core/services/local_db_helper.dart';

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

  Map<String, dynamic> toFireStore(
    String title,
    String description,
    Timestamp deadline,
  ) {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'assignedDate': Timestamp.now(),
      'completedBy': completedBy,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'assignedDate': assignedDate,
      'completedBy': completedBy,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> jsonData) {
    return TaskModel(
      id: jsonData[LocalDbHelper.COLUMN_TASK_ID] as String,
      title: jsonData[LocalDbHelper.COLUMN_TITLE] as String,
      description: jsonData[LocalDbHelper.COLUMN_DESCRIPTION] as String,
      deadline: Timestamp.fromMillisecondsSinceEpoch(jsonData[LocalDbHelper.COLUMN_DEADLINE] as int),
      assignedDate: Timestamp.fromMillisecondsSinceEpoch(jsonData[LocalDbHelper.COLUMN_ASSIGNED_DATE] as int),
      completedBy: jsonData[LocalDbHelper.COLUMN_COMPLETED_BY] != null
          ? List<String>.from(jsonDecode(jsonData[LocalDbHelper.COLUMN_COMPLETED_BY] as String))
          : [],
    );
  }
}
