import 'dart:async';

import 'package:EduLink/core/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../app/app_colors.dart';
import '../../../../core/services/auth_controller.dart';
import '../../../../core/services/local_db_helper.dart';
import '../../../auth/presentaion/screens/signin_screen.dart';
import '../../../profile/data/models/user_model.dart';
import '../../../report and feedback/presentation/screens/report_and_feedback.dart';
import '../../../shared/presentaion/screens/bottom_nav_holder.dart';
import '../../../shared/presentaion/widgets/ShowSnackBarMessage.dart';
import '../../../shared/presentaion/widgets/centered_circular_progress.dart';
import '../../data/models/class_room_model.dart';
import '../controllers/classroom_controller.dart';
import '../widgets/class_room_card.dart';

class MyClassrooms extends StatefulWidget {
  const MyClassrooms({super.key});
  static const name = '/my-classroom';

  @override
  State<MyClassrooms> createState() => _MyClassroomsState();
}

class _MyClassroomsState extends State<MyClassrooms> {
  final user = FirebaseAuth.instance.currentUser;
  final ClassRoomController _classRoomController =
      Get.find<ClassRoomController>();
  StreamSubscription<List<ConnectivityResult>>? subscription;
  bool isOffline = false;

  late Future<List<ClassRoomModel>> _myClassesFuture = Future.value([]);

  UserModel userModel =
      AuthController.user ??
      UserModel(uid: "", name: "", email: "", photoUrl: "");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _initConnectivity();
    });
  }

  Future<void> _initConnectivity() async {

    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = connectivityResult.contains(ConnectivityResult.none);
    });
    debugPrint(isOffline?"You are offline Now":'You are online now');
    _myClassesFuture = _fetchClasses();

    //this will listen for future changes
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final wasOffline = isOffline;
      final nowOffline = result.contains(ConnectivityResult.none);
      debugPrint(nowOffline ? "You are offline now" : "You are online now");
      if(wasOffline != nowOffline){
        setState(() {
          isOffline = nowOffline;
          _myClassesFuture = _fetchClasses();
        });
      }
    });
  }

  Future<List<ClassRoomModel>> _fetchClasses() async {
    if (user != null && isOffline == false) {
      print(user!.uid);
      await _classRoomController.getMyClasses(user!.uid);

      return _classRoomController.myClassList;
    } else if (isOffline == true) {
      LocalDbHelper dbHelper = LocalDbHelper.getInstance();
      return await dbHelper.getAllClasses();
    }
    return [];
  }

  @override
  void dispose() {
    ConnectivityService().isOffline.removeListener(_initConnectivity);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.catalinaBlueThemeColor,
                    AppColors.mediumThemeColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
              ),
              accountName: Text(
                userModel.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(userModel.email),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.black87,
              ),
              title: const Text("Report and feedback"),
              onTap: () {
                Navigator.pushNamed(context, ReportAndFeedback.name);
              },
            ),
            const Divider(),


            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () async {
                print(AuthController.user);
                await FirebaseAuth.instance.signOut();
                AuthController.user = null;
                AuthController.classDocId = null;
                AuthController.isAdmin = false;
                await Get.find<AuthController>().clearUserData();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  SigninScreen.name,
                  (predicate) => false,
                );
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(SigninScreen.name);
                }
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.themeColor,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "My Classrooms",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: FutureBuilder<List<ClassRoomModel>>(
        future: _myClassesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenteredCircularProgress();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No classrooms found."));
          }

          final myClasses = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView.builder(
              itemCount: myClasses.length,
              itemBuilder: (context, index) {
                return ClassroomCard(
                  classroom: myClasses[index],
                  onTap: (){
                    AuthController.currentClassRoom = myClasses[index];
                    AuthController.classDocId = myClasses[index].id;
                    Navigator.pushNamed(context, BottomNavHolder.name);
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await joinClassDialog();
                  setState(() {});
                },
                icon: const Icon(Icons.group_add, color: Colors.white),
                label: const Text(
                  "Join a Class",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: createClassDialog,
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  "Create a Class",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> joinClassDialog() async {
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          elevation: 10,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Join a Class",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.themeColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Class Code TextField
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: "Enter class code",
                    prefixIcon: Icon(
                      Icons.key_rounded,
                      color: AppColors.mediumThemeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text("Cancel"),
                    ),
                    GetBuilder<ClassRoomController>(
                      builder: (controller) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColor,
                          ),
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final code = codeController.text.trim();
                                  if (code.isEmpty) {
                                    ShowSnackBarMessage(
                                      context,
                                      "Please Enter Class Code",
                                    );
                                    return;
                                  }

                                  bool result = await controller.joinClass(
                                    code,
                                    user!.uid,
                                  );

                                  if (result) {
                                    setState(() {
                                      _myClassesFuture = _fetchClasses();
                                    });
                                    ShowSnackBarMessage(
                                      context,
                                      "Joined Successfully",
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    print('Here');
                                    Navigator.pop(context);
                                    ShowSnackBarMessage(
                                      context,
                                      controller.errorMessage ??
                                          "Failed to join class",
                                    );
                                  }
                                },
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Join",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> createClassDialog() async {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          elevation: 10,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Create a Class",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.themeColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Class Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Class name",
                    prefixIcon: Icon(
                      Icons.class_,
                      color: AppColors.mediumThemeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Subject
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: "Subject",
                    prefixIcon: Icon(
                      Icons.book_rounded,
                      color: AppColors.mediumThemeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text("Cancel"),
                    ),
                    GetBuilder<ClassRoomController>(
                      builder: (controller) {
                        print("Loading: ${controller.isLoading}");
                        return controller.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.themeColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.themeColor,
                                ),
                                onPressed: () async {
                                  final name = nameController.text.trim();
                                  final subject = subjectController.text.trim();

                                  if (name.isEmpty || subject.isEmpty) {
                                    ShowSnackBarMessage(
                                      context,
                                      "Please fill all fields",
                                    );
                                    return;
                                  }

                                  if (user != null) {
                                    ClassRoomModel model = ClassRoomModel(
                                      name: name,
                                      subject: subject,
                                      createdBy: user!.uid,
                                      createdAt: Timestamp.now(),
                                      students: [user!.uid],
                                      admins: [user!.uid],
                                    );

                                    final result = await controller.createClass(
                                      model,
                                      user!.uid,
                                    );
                                    if (result) {
                                      setState(() {
                                        _myClassesFuture = _fetchClasses();
                                      });
                                    }
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  "Create",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
