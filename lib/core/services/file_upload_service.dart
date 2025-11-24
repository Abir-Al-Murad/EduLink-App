import 'dart:io';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/features/task/data/model/attachments_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class FileUploadService extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AttachmentsModel? _uploadedFileInfo;
  AttachmentsModel? get uploadedFileInfo => _uploadedFileInfo;


  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'pptx',
          'xls',
          'xlsx',
        ],
      );
      debugPrint(result?.files.single.path);
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint("Error picking file : $e");
      return null;
    }
  }

  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint("Error picking image : $e");
      return null;
    }
  }

  Future<AttachmentsModel?> uploadFile(File file, String studentId, String taskId,String studentName) async {
    try {
      String fileName = const Uuid().v4();
      final storageRef = _storage.ref().child('uploads/$fileName');

      UploadTask uploadTask = storageRef.putFile(file,SettableMetadata(
        contentType: lookupMimeType(file.path),
        customMetadata: {
          'studentId':studentId,
          'originalFileName':basename(file.path),
        }
      ));

      uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred / event.totalBytes;
        print("Upload: ${(progress * 100).toStringAsFixed(2)}%");
      });


      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      AttachmentsModel model = AttachmentsModel(
        fileUrl: downloadUrl,
        studentId: studentId,
        fileName: basename(file.path),
        uploadedAt: Timestamp.now(), studentName:studentName,
      );
      _firestore
          .collection(Collectons.classes)
          .doc(AuthController.classDocId)
          .collection(Collectons.tasks)
          .doc(taskId)
          .set({'attachments':FieldValue.arrayUnion([model.toMap()]) }, SetOptions(merge: true));
      return model;
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }


}
