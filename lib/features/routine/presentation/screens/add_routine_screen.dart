import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universityclassroommanagement/app/app_colors.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key, required this.day});

  static const name = '/add-routine';

  final  String day;

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();


  Future<void> _addRoutine() async {
    if (_formKey.currentState!.validate()) {
      final routineData = {
        'course': _courseController.text.trim(),
        'teacher': _teacherController.text.trim(),
        'room': _roomController.text.trim(),
        'time': _timeController.text.trim(),
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection(Collectons.classes).doc(AuthController.classDocId)
          .collection(Collectons.routine)
          .doc(widget.day)
          .collection(Collectons.dayRoutine)
          .add(routineData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Routine added successfully!')),
      );

      _courseController.clear();
      _teacherController.clear();
      _roomController.clear();
      _timeController.clear();
      Navigator.pop(context,true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Routine")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: "Course Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter course name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: "Teacher Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Enter teacher name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: "Room No",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter room no" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: "Class Time (e.g., 10:00 AM - 11:30 AM)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter time" : null,
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _addRoutine,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.themeColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
