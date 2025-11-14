import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/app/app_colors.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:EduLink/features/profile/data/models/user_model.dart';
import 'package:EduLink/features/profile/presentaion/screens/members_list_screen.dart';
import 'package:EduLink/features/shared/presentaion/controllers/main_nav_controller.dart';
import 'package:EduLink/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        SnackBar(content: Text("Error fetching profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Class",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: AppColors.themeColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userModel == null
          ? const Center(child: Text("User not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.royalThemeColor,
              child: Text(
                AuthController.currentClassRoom!.name.isNotEmpty
                    ? AuthController.currentClassRoom!.name[0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AuthController.currentClassRoom!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            // Subject
            Text(
              AuthController.currentClassRoom!.subject,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Divider(thickness: 1.2),
            const SizedBox(height: 10),

            // Info Tiles
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.code, color: AppColors.themeColor),
                title: const Text("Class Code"),
                trailing: Text(
                  "${AuthController.classDocId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(context, MembersListScreen.name);
                },
                leading:  Icon(Icons.people_alt, color: AppColors.themeColor),
                title: const Text('Members'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ),

            if (userModel!.lastLogin != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.themeColor),
                  title: const Text("Last Login"),
                  subtitle: Text(
                    (userModel!.lastLogin!.toDate()).toString(),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onTapLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Leave the group",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onTapBackToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Back to classrooms",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              "No",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
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
