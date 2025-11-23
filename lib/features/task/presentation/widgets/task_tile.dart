import 'package:flutter/material.dart';
import 'package:EduLink/features/task/data/model/task_model.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';

import '../../../../app/app_colors.dart';

class TaskTile extends StatelessWidget {
  final int index;
  final TaskModel taskModel;
  final bool IsCompletedTask;

  const TaskTile({super.key, required this.index, required this.taskModel, required this.refresh,required this.IsCompletedTask});

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
                  color:  AppColors.themeColor.withOpacity(0.3),
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
                      IsCompletedTask?Icons.done_all_outlined:Icons.access_time,
                      size: 12,
                      color: _getDeadlineIconColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      IsCompletedTask?"Task Completed":"Due: ${formatDate(taskModel.deadline)}",
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
        ),
      ),
    );
  }

  Color _getDeadlineColor(BuildContext context) {

    if(IsCompletedTask){
      return Colors.green.shade50;
    }
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
    if(IsCompletedTask){
      return Colors.green.shade600;
    }
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
}
