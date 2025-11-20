import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/notification_sevice.dart';
import 'package:EduLink/features/task/data/model/task_model.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:get/get.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.taskModel});
  final TaskModel taskModel;
  static const name = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TaskModel taskModel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    taskModel = widget.taskModel;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: Text('Task Details')),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Status Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Completion Status Badge
                      Row(
                        children: [
                          Expanded(child: _buildStatusBadge()),
                          _buildPriorityBadge(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Task Title
                      Text(
                        taskModel.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Deadline Info Card
                      _buildDeadlineCard(),

                      const SizedBox(height: 20),

                      // Completion Progress
                      _buildCompletionProgress(),
                    ],
                  ),
                ),

                // Description Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: AppColors.themeColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          taskModel.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: !_isTaskCompleted() ? _buildCompleteButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatusBadge() {
    final isCompleted = _isTaskCompleted();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.pending_outlined,
            color: isCompleted ? Colors.green.shade600 : Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? "Completed" : "Pending",
            style: TextStyle(
              color: isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final color = _getDeadlineIconColor();
    final status = _getDeadlineStatus();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.contains('Overdue')
                ? 'Overdue'
                : status.contains('today')
                ? 'Urgent'
                : 'Active',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard() {
    final color = _getDeadlineIconColor();
    final status = _getDeadlineStatus();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(taskModel.deadline),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            status.contains('Overdue')
                ? Icons.error_outline
                : status.contains('today')
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: color,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionProgress() {
    final totalStudents = AuthController.currentClassRoom!.students.length;
    final completedCount = taskModel.completedBy.length;
    final percentage = (completedCount / totalStudents * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Completion Rate",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              "$completedCount/$totalStudents students",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: completedCount / totalStudents,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.themeColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.themeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "$percentage% completed",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      // height: 56,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: AppColors.themeColor.withOpacity(0.4),
      //       blurRadius: 20,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: () {

            },
            label: Text('Add Attachment'),
            icon: Icon(Icons.add),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppColors.themeColor),
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: Size(double.maxFinite, 48)
            ),
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: _isCompleting ? null : _markAsComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isCompleting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Mark as Complete",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _getDeadlineIconColor() {
    if (_isTaskCompleted()) {
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

  String _getDeadlineStatus() {
    if (_isTaskCompleted()) {
      return 'Task Completed';
    }
    final now = DateTime.now();
    final deadlineDate = taskModel.deadline.toDate();
    final difference = deadlineDate.difference(now).inDays;

    if (difference < 0) {
      return "Overdue by ${difference.abs()} day${difference.abs() == 1 ? '' : 's'}";
    } else if (difference == 0) {
      return "Due today";
    } else if (difference == 1) {
      return "Due tomorrow";
    } else {
      return "Due in $difference days";
    }
  }

  bool _isTaskCompleted() {
    return taskModel.completedBy.contains(AuthController.user!.uid);
  }

  Future<void> _markAsComplete() async {
    setState(() => _isCompleting = true);

    try {
      List<String> completedBy = List.from(taskModel.completedBy);
      if (!completedBy.contains(AuthController.user!.uid)) {
        completedBy.add(AuthController.user!.uid);
      }

      await FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(AuthController.classDocId)
          .collection(Collectons.tasks)
          .doc(taskModel.id)
          .update({'completedBy': completedBy});

      // Update local model
      setState(() {
        taskModel = TaskModel(
          id: taskModel.id,
          title: taskModel.title,
          description: taskModel.description,
          deadline: taskModel.deadline,
          completedBy: completedBy,
          assignedDate: taskModel.assignedDate,
        );
      });

      NotificationService notificationService = NotificationService();
      await notificationService.cancelTaskNotifications(taskModel.id!);

      if (mounted) {
        Get.snackbar(
          'Mark as Completed',
          "🎉 ${taskModel.title} marked as completed",
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Failed', "❌ Error marking task as complete");
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }
}
