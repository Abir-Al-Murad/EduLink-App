import 'package:EduLink/features/task/data/model/attachments_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../app/collections.dart';
import '../../data/model/task_model.dart';

class TaskController extends GetxController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  Future<bool> addNewTask(TaskModel model, String classDocId) async {
    _isLoading = true;
    try {
      final taskCollection = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(classDocId)
          .collection(Collectons.tasks);

      await taskCollection.add(
        model.toFireStore(),
      );
      print('Task Added at : ${classDocId}');
      _isLoading = false;
      update();
      return true; // success
    } catch (e) {
      print("Add Task Error: $e");
      _isLoading = false;
      update();
      return false; // failed
    }
  }

  Future<bool> deleteTask(String id, String classDocId) async {
    _isLoading = true;
    update();
    try {
      final taskCollection = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(classDocId)
          .collection(Collectons.tasks);
      await taskCollection.doc(id).delete();
      update();
      return true;
    } catch (e) {
      print("Delete Task Error: $e");
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<bool> addAttachment(AttachmentsModel model,String classId,String taskId)async{
    bool isSuccess = false;
    _isLoading = true;
    update();
    try{
      FirebaseFirestore.instance.collection(Collectons.classes).doc(classId).collection(Collectons.tasks).doc(taskId).update(model.toMap());
      isSuccess = true;

    }catch(e){
      isSuccess = false;
      debugPrint("Failed to add attachment at Task - $taskId");
    }
    _isLoading = false;
    update();
    return isSuccess;
  }
}
