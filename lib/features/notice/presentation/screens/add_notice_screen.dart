import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/features/notice/data/models/notice_model.dart';
import 'package:universityclassroommanagement/features/notice/presentation/controllers/add_notice_controler.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/ShowSnackBarMessage.dart';

class AddNotice extends StatefulWidget {
  const AddNotice({super.key});
  static const name = '/add-notice';
  @override
  State<AddNotice> createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Notice"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            GetBuilder<AddNoticeController>(
              builder: (controller) {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Visibility(
                    visible: controller.isLoading == false,
                    replacement: Center(child: CircularProgressIndicator(),),
                    child: ElevatedButton(
                      onPressed: ()async{
                        NoticeModel model = NoticeModel(title: _titleController.text.trim(), description: _descriptionController.text.trim(), createdAt: Timestamp.now());
                        bool result = await controller.addNotice(model);
                        if(result){
                          ShowSnackBarMessage(context, "Notice Added Successfully");
                          Navigator.pop(context,true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:Text(
                        "Post Notice",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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
}
