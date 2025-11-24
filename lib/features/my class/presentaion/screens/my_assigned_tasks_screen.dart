import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/collections.dart';
import '../../../task/data/model/task_model.dart';
import 'submissions_list_screen.dart';

class MyAssignedTasksListScreen extends StatelessWidget {
  const MyAssignedTasksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthController.user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks I Assigned"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Collectons.classes)
            .doc(AuthController.classDocId)
            .collection(Collectons.tasks)
            .where("createdBy", isEqualTo: currentUserId)
            .orderBy("assignedDate", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No tasks assigned yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final task = TaskModel.fromFireStore(
                docs[index].data(),
                docs[index].id,
              );

              final isOverdue = task.deadline.toDate().isBefore(DateTime.now());

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOverdue ? Colors.red.shade100 : Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isOverdue ? Colors.red.shade50 : Colors.white,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        "Deadline: ${formatDate(task.deadline)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (isOverdue)
                        Text(
                          "Overdue",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubmissionsListScreen(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}