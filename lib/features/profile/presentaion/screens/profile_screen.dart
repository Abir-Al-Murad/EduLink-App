import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signin_screen.dart';
import 'package:universityclassroommanagement/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:universityclassroommanagement/features/profile/presentaion/screens/members_list_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/controllers/main_nav_controller.dart';
import '../../../shared/data/model/user_model.dart';

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
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
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
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userModel!.photoUrl!),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              userModel!.name!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),
            // Email
            Text(
              userModel!.email!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Joined Classes
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text("Joined Classes"),
              trailing:
              Text("${userModel!.joinedClasses.length} classes"),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text("Class Code"),
              trailing:
              Text("${AuthController.classDocId}"),
            ),
            ListTile(
              onTap: (){
                Navigator.pushNamed(context, MembersListScreen.name);
              },
              leading: const Icon(Icons.people_alt),
              title: Text('Members'),
            ),

            // Last Login
            if (userModel!.lastLogin != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Last Login"),
                subtitle: Text(
                  (userModel!.lastLogin!.toDate()).toString(),
                ),
              ),

            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: (){

              print("Data is Auth : ${AuthController.user!.name}");
              Navigator.pushNamedAndRemoveUntil(context, MyClassrooms.name, (predicate)=>false);
            }, child: Text("Back To Home",style: TextStyle(color: Colors.white),))
          ],
        ),
      ),
    );
  }
}
