import 'dart:io';

import 'package:EduLink/core/services/file_upload_service.dart';
import 'package:EduLink/features/shared/presentaion/utils/get_deadline_status.dart';
import 'package:EduLink/features/shared/presentaion/utils/open_file_preview.dart';
import 'package:EduLink/features/task/data/model/attachments_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/notification_sevice.dart';
import 'package:EduLink/features/task/data/model/task_model.dart';
import 'package:EduLink/features/shared/presentaion/widgets/format_Date.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:get/get.dart';
import '../../../shared/presentaion/utils/get_deadline_color.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.taskModel});
  final TaskModel taskModel;
  static const name = '/task-details';

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TaskModel model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  AttachmentsModel? attachmentsModel;
  FileUploadService _uploadService = Get.find<FileUploadService>();
  bool _isSubmitting = false;
  bool _isUndoing = false;
  File? pickedFile;
  String? url;
  String? fileName;
  bool _needRefresh = false;
  ValueNotifier<bool> _isCompleted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    model = widget.taskModel;
    _isCompleted.value = _isTaskCompleted();
    loadAttachment();
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

  Future<void> loadAttachment() async {
    if(widget.taskModel.attachments.isNotEmpty){
      attachmentsModel = widget.taskModel.attachments.firstWhere(
            (e) => e.studentId == AuthController.userId,
      );
      url = attachmentsModel!.fileUrl;
      fileName = attachmentsModel!.fileName;
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.taskModel.attachments.where((e)=>e.studentId == AuthController.userId));
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pop(context,true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
            leading: BackButton(
              onPressed: (){
                Navigator.pop(context,_needRefresh);
              },
            ),
            title: Text('Task Details')),
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
                          model.title,
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
                            model.description,
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

        floatingActionButton:_buildCompleteButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
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
    final color = getDeadlineIconColor(_isCompleted.value,model.deadline.toDate());
    final status = getDeadlineStatus(model.deadline.toDate());

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
    final color = getDeadlineIconColor(_isCompleted.value,model.deadline.toDate());
    final status = getDeadlineStatus(model.deadline.toDate());

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
                  formatDate(model.deadline),
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
    final completedCount = model.completedBy.length;
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
    print("isCompleted :${_isCompleted.value}");
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed:_isCompleted.value?null:_onTapAttachment,
            child: pickedFile == null && url == null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.attach_file),
                SizedBox(width: 8),
                Text("Add Attachment"),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // filename
                Expanded(
                  child: Text(pickedFile !=null?
                    pickedFile!.path.split('/').last:fileName!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // View button
                IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {
                    openFilePreview(context, pickedFile, url);
                  },
                ),

                // Remove file
                if(url == null && _isCompleted.value == false)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        pickedFile = null;
                      });
                    },
                  ),

              ],
            ),
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
            onPressed:  !_isCompleted.value? (_isSubmitting ? null : _submitTask):(_isUndoing?null:_withdrawSubmission),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.themeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isSubmitting || _isUndoing
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          :
                      _isCompleted.value == false?const Icon(Icons.check_circle_outline, size: 24):Icon(Icons.arrow_upward,color: Colors.yellow,),
                      const SizedBox(width: 12),
                      Text(
                        !_isCompleted.value? "Submit Task":"Withdraw Submission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: _isCompleted.value?Colors.amberAccent:Colors.white
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  Future<void> _onTapAttachment()async{
    if(pickedFile ==null && url == null){
      pickedFile = await _uploadService.pickFile();
      setState(() {});
    }else{

    }
  }
  Future<void> _withdrawSubmission() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(AuthController.classDocId)
          .collection(Collectons.tasks)
          .doc(model.id);

      // 1️⃣ Load latest document
      final snap = await docRef.get();
      final data = snap.data()!;

      // 2️⃣ Find this student's attachment
      final List attachments = data['attachments'] ?? [];

      final studentAttachment = attachments.firstWhere(
            (a) => a['studentId'] == AuthController.userId,
        orElse: () => null,
      );

      // 3️⃣ Remove attachment
      if (studentAttachment != null) {
        await docRef.update({
          'attachments': FieldValue.arrayRemove([studentAttachment])
        });

        // Delete from Storage
        await FirebaseStorage.instance
            .refFromURL(studentAttachment['fileUrl'])
            .delete();
      }

      // 4️⃣ Remove from completedBy
      await docRef.update({
        'completedBy': FieldValue.arrayRemove([AuthController.userId])
      });

      // 5️⃣ Local UI update
      setState(() {
        attachmentsModel = null;
        url = null;
        fileName = null;
        _isCompleted.value = false;
        model.completedBy.remove(AuthController.userId);
        pickedFile = null;
      });

      Get.snackbar("Success", "Submission withdrawn");

    } catch (e) {
      Get.snackbar("Error", "❌ Failed: $e");
    }
  }


  bool _isTaskCompleted() {
    return model.completedBy.contains(AuthController.user!.uid);
  }

  Future<void> _submitTask() async {
    setState(() => _isSubmitting = true);
    _needRefresh = true;

    try {
      final docRef = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(AuthController.classDocId)
          .collection(Collectons.tasks)
          .doc(model.id);

      // 1️⃣ Update completedBy
      List<String> completedBy = List.from(model.completedBy);
      if (!completedBy.contains(AuthController.userId)) {
        completedBy.add(AuthController.userId!);
      }

      await docRef.update({'completedBy': completedBy});

      // 2️⃣ Upload + Save Attachment
      if (pickedFile != null) {
        attachmentsModel = await _uploadService.uploadFile(
          pickedFile!,
          AuthController.userId!,
          model.id!,
          AuthController.user!.name,
        );

        await docRef.update({
          'attachments': FieldValue.arrayUnion([
            attachmentsModel!.toMap()
          ])
        });
      }

      // 3️⃣ Local update
      setState(() {
        model = model.copyWith(completedBy: completedBy);
        url = attachmentsModel?.fileUrl;
        fileName = attachmentsModel?.fileName;
        _isCompleted.value = true;
      });

      NotificationService().cancelTaskNotifications(model.id!);

      Get.snackbar(
        "Task Submitted",
        "🎉 ${model.title} successfully submitted",
      );

    } catch (e) {
      Get.snackbar("Failed", "❌ Error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

}
