import 'package:EduLink/core/services/notification_sevice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/task/data/model/task_model.dart';
import 'package:EduLink/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';

import '../../../../app/app_colors.dart';

class TaskTile extends StatelessWidget {
  final int index;
  final TaskModel taskModel;

  const TaskTile({super.key, required this.index, required this.taskModel, required this.refresh});

  final Function(bool)  refresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: AppColors.themeColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mediumThemeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.themeColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            taskModel.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                taskModel.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDeadlineColor(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: _getDeadlineIconColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Due: ${formatDate(taskModel.deadline)}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getDeadlineIconColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.themeColor,
            ),
          ),
          onTap: () {
            _showTaskDetails(context);
          },
        ),
      ),
    );
  }

  Color _getDeadlineColor(BuildContext context) {
    final now = DateTime.now();
    final deadlineDate = taskModel.deadline.toDate();
    final difference = deadlineDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red.shade50; // Overdue
    } else if (difference == 0) {
      return Colors.orange.shade50; // Due today
    } else if (difference <= 2) {
      return Colors.yellow.shade50; // Due soon
    } else {
      return Colors.green.shade50; // Plenty of time
    }
  }

  Color _getDeadlineIconColor(BuildContext context) {
    final now = DateTime.now();
    final deadlineDate = taskModel.deadline.toDate();
    final difference = deadlineDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red.shade600;
    } else if (difference == 0) {
      return Colors.orange.shade600;
    } else if (difference <= 2) {
      return Colors.orange.shade400;
    } else {
      return Colors.green.shade600;
    }
  }

  void _showTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.themeColor,
                            AppColors.mediumThemeColor,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        taskModel.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  taskModel.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Deadline with colored indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getDeadlineColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDeadlineIconColor(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _getDeadlineIconColor(context),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Deadline",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              formatDate(taskModel.deadline),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getDeadlineIconColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.themeColor,
                          side: BorderSide(color: AppColors.themeColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          List<String> completedBy = taskModel.completedBy;
                          completedBy.add(AuthController.user!.uid);
                          print("CompletedBy : ${taskModel.completedBy}");
                          await FirebaseFirestore.instance
                              .collection(Collectons.classes)
                              .doc(AuthController.classDocId)
                              .collection(Collectons.tasks)
                              .doc(taskModel.id)
                              .update({
                            'completedBy':completedBy,
                          });
                          NotificationService _notificationService = NotificationService();
                          await _notificationService.cancelTaskNotifications(taskModel.id!);
                          ShowSnackBarMessage(context, "${taskModel.title} marked as completed");
                          refresh(true);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Mark Complete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
