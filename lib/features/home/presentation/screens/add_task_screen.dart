import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/home/data/model/task_model.dart';
import 'package:universityclassroommanagement/features/home/presentation/controllers/task_controller.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  static const name = '/add-task';

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TaskController _taskController = Get.find<TaskController>();

  DateTime? deadline;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Add Task"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Deadline Picker
            GestureDetector(
              onTap: pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      deadline == null
                          ? "Pick a deadline"
                          : DateFormat('dd MMM yyyy').format(deadline!),
                      style: TextStyle(
                        fontSize: 16,
                        color: deadline == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            GetBuilder<TaskController>(
              builder: (controller) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Add Task",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
  void submitTask()async{
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        deadline == null) {
      ShowSnackBarMessage(context, "Please fill all fields");
      return;
    }else{
      TaskModel model = TaskModel(title: titleController.text.trim(), description: descriptionController.text.trim(), deadline: Timestamp.fromDate(deadline!));
     final bool isSucces =  await _taskController.addNewTask(model,AuthController.classDocId!);
     if(isSucces){
       titleController.clear();
       descriptionController.clear();
       Navigator.pop(context,true);
       ShowSnackBarMessage(context, "Successfully Added");
     }
    }

    // Firestore save logic
    print("Title: ${titleController.text}");
    print("Description: ${descriptionController.text}");
    print("Deadline: $deadline");
  }


  Future<void> pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }
  
}
