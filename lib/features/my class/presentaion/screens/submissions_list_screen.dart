import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/my%20class/presentaion/widgets/stats_card.dart';
import 'package:EduLink/features/my%20class/presentaion/widgets/submission_list.dart';
import 'package:EduLink/features/task/data/model/attachments_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../app/collections.dart';
import '../../../task/data/model/task_model.dart';

class SubmissionsListScreen extends StatelessWidget {
  final TaskModel task;

  const SubmissionsListScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "${task.title} - Submissions",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Collectons.classes)
            .doc(AuthController.classDocId)
            .collection(Collectons.tasks)
            .doc(task.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final taskData = snapshot.data;
          if (taskData == null) {
            return Center(child: Text("No data found."));
          }
          final List<dynamic> rawAttachments = taskData["attachments"] ?? [];
          final attachmentModelList = rawAttachments.map((e)=>AttachmentsModel.fromMap(e)).toList();
          final totalStudents = (taskData['completedBy'] as List).length; // Replace with actual total students count
          final submissionCount = rawAttachments.length;
          final submissionPercentage = (submissionCount / totalStudents * 100).round();

          return Column(
            children: [
              // Submission Stats Card
              StatsCard(submitted: submissionCount,total: totalStudents, percentage: submissionPercentage,),
              // Submissions List
              Expanded(
                child: SubmissionList(attachments: attachmentModelList,submissionCount: submissionCount,deadline: taskData['deadline'],),
              ),
            ],
          );
        },
      ),
    );
  }

}