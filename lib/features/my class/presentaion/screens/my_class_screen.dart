import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:EduLink/features/shared/presentaion/controllers/main_nav_controller.dart';
import 'package:EduLink/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

import '../../data/models/user_model.dart';
import 'members_list_screen.dart';
import 'my_assigned_tasks_screen.dart';

class MyClassScreen extends StatefulWidget {
  const MyClassScreen({super.key});

  @override
  State<MyClassScreen> createState() => _MyClassScreenState();
}

class _MyClassScreenState extends State<MyClassScreen> {
  UserModel? userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userModel = UserModel.fromFireStore(doc.data()!);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching my class: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Class",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userModel == null
          ? const Center(child: Text("User not found"))
          : Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.mediumThemeColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AuthController.currentClassRoom!.name.isNotEmpty
                                  ? AuthController.currentClassRoom!.name[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AuthController.currentClassRoom!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthController.currentClassRoom!.subject,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info Cards
                  _buildInfoCard(),
                  const SizedBox(height: 10,),
                  _buildTaskSection(),


                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTaskSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.assignment_outlined, color: AppColors.themeColor),
        title: Text(
          "Tasks I Assigned",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MyAssignedTasksListScreen()),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Class Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Class Code
          _buildInfoRow(
            icon: Icons.code_rounded,
            title: "Class Code",
            value: "${AuthController.classDocId}",
            isCopyable: true,
          ),

          const SizedBox(height: 12),

          // Members
          _buildInfoRow(
            icon: Icons.people_alt_rounded,
            title: "Members",
            value: "View all members",
            isClickable: true,
            onTap: () {
              Navigator.pushNamed(context, MembersListScreen.name);
            },
          ),

          if (userModel!.lastLogin != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              title: "Last Login",
              value: userModel!.lastLogin!.toDate().toString(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isClickable = false,
    bool isCopyable = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.themeColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isClickable
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.themeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.themeColor,
                size: 12,
              ),
            ],
          ),
        )
            : Text(
          value.length > 15 ? '${value.substring(0, 15)}...' : value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: isClickable ? onTap : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Leave Group Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade200,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _onTapLeave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Leave the Group",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Back to Classrooms Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.themeColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _onTapBackToHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Back to Classrooms",
                  style: TextStyle(
                    color: AppColors.themeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onTapBackToHome() {
    Get.find<MainNavControler>().backToHome();
    AuthController.authClear();
    Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate) => false);
  }

  Future<void> _onTapLeave() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Leave Class?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to leave '${AuthController.currentClassRoom!.name}'?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Yes, Leave",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    try {
      final classRoom = AuthController.currentClassRoom!;
      final currentUser = AuthController.user!;

      debugPrint("Before Removing , your students : ${classRoom.students}");
      classRoom.students.remove(currentUser.uid);
      print("After Removing a student from classes : ${classRoom.students}");
      final classRef = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(AuthController.classDocId);
      final userRef = FirebaseFirestore.instance
          .collection(Collectons.users)
          .doc(currentUser.uid);

      if (classRoom.students.isEmpty) {
        await classRef.delete();
      } else {
        await classRef.update(classRoom.toFireStore());
      }
      debugPrint("Before Removing , your joined classes : ${AuthController.user!.joinedClasses}");

      currentUser.joinedClasses.removeWhere((id){
        return AuthController.classDocId == id;
      });
      currentUser.joinedClasses.remove(AuthController.classDocId);
      print("After Removing a class ref: ${currentUser.joinedClasses}");
      await userRef.set(currentUser.toFireStore());
      Get.find<MainNavControler>().backToHome();
      ShowSnackBarMessage(
        context,
        "Successfully left from ${classRoom.name}",
      );

      AuthController.authClear();
      Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate) => false);
    } catch (e) {
      ShowSnackBarMessage(context, "Failed to leave class: $e");
    }
  }
}