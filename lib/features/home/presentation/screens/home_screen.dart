import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/app_colors.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/home/data/model/task_model.dart';
import 'package:universityclassroommanagement/features/home/presentation/controllers/task_controller.dart';
import 'package:universityclassroommanagement/features/home/presentation/screens/add_task_screen.dart';
import 'package:universityclassroommanagement/features/home/presentation/widgets/task_tile.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/show_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const name = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    print(AuthController.classDocId);
    print(AuthController.isAdmin);
    return Scaffold(
      appBar: AppBar(
        title: Text("StudyHub"),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection(Collectons.classes)
            .doc(AuthController.classDocId)
            .collection(Collectons.tasks)
            .orderBy('assignedDate', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Some Error Occur"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No Data Found"));
          }

          final docs = snapshot.data!.docs;
          final user = FirebaseAuth.instance.currentUser!.uid;

          final listOfData = docs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final doneList = data['completedBy'] != null
                ? List<String>.from(data['completedBy'])
                : <String>[];
            return !doneList.contains(user);
          })
              .map((doc) => TaskModel.fromFireStore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderContainer(),
            
                  const SizedBox(height: 20),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tasks",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if(AuthController.isAdmin)
                        FilledButton(
                          onPressed: ()async {
                            await onTapAddToTask();
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.royalThemeColor,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                              )
                          ),
                          child: Text(
                            "Add Task",
                            style: TextStyle(fontSize: 14), // smaller text
                          ),
                        ),

                    ],
                  ),
            
                  SizedBox(height: 10,),
            
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listOfData.length,
                    itemBuilder: (context, index) {
                      final item = listOfData[index];
                      return GestureDetector(
                        onLongPress: () {
                          buildShowDialog(context, item);
                        },
                        child: TaskTile(
                          title: item.title,
                          description: item.description,
                          deadline: item.deadline,
                          index: index,
                        ),
                      );

                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Future<void> onTapAddToTask()async{
    final   result =await Navigator.pushNamed(context, AddTaskScreen.name);
    if(result == true){
      setState(() {});
    }
  }


  Widget _buildHeaderContainer() {
    return Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.themeColor,
                        AppColors.mediumThemeColor,
                        AppColors.royalThemeColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // University Badge Style Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.shade400, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              "7A",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a237e),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 25),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUniversityStat(Icons.assignment, "Assignments", "12"),
                              SizedBox(height: 16),
                              _buildUniversityStat(Icons.quiz, "Class Tests", "8"),
                              SizedBox(height: 16),
                              _buildUniversityStat(Icons.slideshow, "Presentations", "5"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
  }


  Widget _buildUniversityStat(IconData icon, String label, String count) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.amber.shade400.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
