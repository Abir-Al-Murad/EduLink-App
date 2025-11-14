import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../../app/collections.dart';
import '../../data/model/task_model.dart';

class TaskController extends GetxController{

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<bool> addNewTask(TaskModel model,String classDocId) async {
    _isLoading = true;
    try {
      final taskCollection = FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(classDocId)
          .collection(Collectons.tasks);


      await taskCollection.add(model.toFireStore(
        model.title,
        model.description,
        model.deadline,
      ));
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

  Future<bool> deleteTask(String id,String classDocId) async {
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
    }finally{
      _isLoading = false;
      update();
    }
  }



}