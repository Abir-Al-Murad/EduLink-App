import 'dart:io';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/file_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../../../my class/data/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const name = '/edit-my class';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _pickedImage;
  String? photoUrl;
  final TextEditingController nameController = TextEditingController();
  UserModel? model;
  ValueNotifier<bool>isLoading = ValueNotifier(false);

  FileUploadService _uploadService = Get.find<FileUploadService>();


  Future<void> _fetchUserInfo()async{
    final doc = await FirebaseFirestore.instance.collection(Collectons.users).doc(AuthController.userId).get();
    final userData = doc.data();
    final userModel = UserModel.fromFireStore(userData!);
    model = userModel;
    photoUrl = userModel.photoUrl;
    nameController.text = userModel.name;

  }

  @override
  void initState() {
    _fetchUserInfo();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (photoUrl != null && photoUrl!.isNotEmpty
                        ? NetworkImage(photoUrl!)
                        : null),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: ()async{
                        _pickedImage = await _uploadService.pickImage(source: ImageSource.gallery);
                        if(_pickedImage !=null){
                          setState(() {

                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            ValueListenableBuilder(
              builder: (context,bool,child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading.value?null:_onTapSave,
                    child: isLoading.value?CircularProgressIndicator():const Text("Save Changes",style: TextStyle(color: Colors.white),),
                  ),
                );
              }, valueListenable: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapSave() async {
    isLoading.value = true;


    try {
      // Upload my class image if picked
      if (_pickedImage != null) {
        String fileName = const Uuid().v4();

        final storageRef =
        FirebaseStorage.instance.ref().child('uploads/profile_pics/$fileName');

        UploadTask uploadTask = storageRef.putFile(
          _pickedImage!,
          SettableMetadata(
            contentType: lookupMimeType(_pickedImage!.path),
            customMetadata: {
              'studentId': model!.uid,
              'originalFileName': basename(_pickedImage!.path),
            },
          ),
        );

        TaskSnapshot snapshot = await uploadTask;
        photoUrl = await snapshot.ref.getDownloadURL();
      }

      // 🔥 IMPORTANT: Update model using copyWith
      model = model!.copyWith(
        name: nameController.text.trim(),
        photoUrl: photoUrl,
      );

      // Save updated data to Firestore
      await FirebaseFirestore.instance
          .collection(Collectons.users)
          .doc(AuthController.userId)
          .update(model!.toFireStore());

      Get.snackbar("Updated", "Profile updated successfully");
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to update your my class");
    }

    isLoading.value = false;
  }

}
