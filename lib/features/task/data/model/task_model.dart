import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/local_db_helper.dart';
import 'attachments_model.dart';

class TaskModel {
  final String? id;
  final String title;
  final String description;
  final Timestamp deadline;
  final Timestamp? assignedDate;
  final List<String> completedBy;
  final List<AttachmentsModel> attachments;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.assignedDate,
    this.completedBy = const [],
    this.attachments = const [],
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
      attachments: jsonData['attachments'] !=null ? (jsonData['attachments'] as List).map((e)=>AttachmentsModel.fromMap(e)).toList():[]
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'assignedDate': Timestamp.now(),
      'completedBy': completedBy,
      'attachments': attachments,
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
    try {
      int parseTimestamp(dynamic value) {
        if (value == null) return DateTime.now().millisecondsSinceEpoch;
        if (value is int) return value;
        if (value is String) return int.parse(value);
        return DateTime.now().millisecondsSinceEpoch;
      }

      return TaskModel(
        id: jsonData[LocalDbHelper.COLUMN_TASK_ID] as String,
        title: jsonData[LocalDbHelper.COLUMN_TITLE] as String,
        description: jsonData[LocalDbHelper.COLUMN_DESCRIPTION] as String? ?? '',

        // ✅ Parse string to int first
        deadline: Timestamp.fromMillisecondsSinceEpoch(
            parseTimestamp(jsonData[LocalDbHelper.COLUMN_DEADLINE])),

        assignedDate: jsonData[LocalDbHelper.COLUMN_ASSIGNED_DATE] != null
            ? Timestamp.fromMillisecondsSinceEpoch(
            parseTimestamp(jsonData[LocalDbHelper.COLUMN_ASSIGNED_DATE]))
            : null,

        // ✅ Handle completedBy - it's already a JSON string
        completedBy: jsonData[LocalDbHelper.COLUMN_COMPLETED_BY] != null &&
            (jsonData[LocalDbHelper.COLUMN_COMPLETED_BY] as String).isNotEmpty
            ? List<String>.from(jsonDecode(jsonData[LocalDbHelper.COLUMN_COMPLETED_BY] as String))
            : [],
      );
    } catch (e) {
      debugPrint("❌ Error parsing TaskModel from map: $e");
      debugPrint("Data: $jsonData");
      rethrow;
    }
  }
}


