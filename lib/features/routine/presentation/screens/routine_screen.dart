import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/routine/data/models/routine_model.dart';
import 'package:universityclassroommanagement/features/routine/presentation/screens/add_routine_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/icon_filled_button.dart';

import '../widgets/routine_card.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday"
  ];


  late String today;
  @override
  void initState() {
    final DateTime now = DateTime.now();
    today = DateFormat('EEEE').format(now);
    _tabController = TabController(length: days.length, vsync: this,initialIndex: days.indexOf(today));
    super.initState();
  }

  Future<List<RoutineModel>> fetchRoutine(String day) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(Collectons.classes).doc(AuthController.classDocId).collection(Collectons.routine)
        .doc(day)
        .collection(Collectons.dayRoutine)
        .orderBy('time', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => RoutineModel.fromFireStore(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routine"),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.blueAccent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: days.map((d) => Tab(text: d)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: days.map((day) {
                return Column(
                  children: [
                    Expanded(
                      child: FutureBuilder<List<RoutineModel>>(
                        future: fetchRoutine(day),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text("Error loading $day routine"));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                                child: Text(
                                  "No classes found for $day",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ));
                          }

                          final classes = snapshot.data!;
                          return Column(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: classes.length,
                                      itemBuilder: (context, index) {
                                        final item = classes[index];
                                        return RoutineCard(item: item,index:index);
                                      },
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          );
                        },
                      ),
                    ),

                  ],
                );
              }).toList(),
            ),
          ),
          if(AuthController.isAdmin)
            IconFilledButton(onTap: onTapAddRoutine, title: "Add Routine")
        ],
      ),
    );
  }

  Future<void>onTapAddRoutine()async{
    final result = await Navigator.pushNamed(context, AddRoutineScreen.name,arguments: days[_tabController.index]);
            if(result == true){
              setState(() {});
            }
  }
}

