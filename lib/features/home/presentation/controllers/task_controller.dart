import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/features/home/data/model/task_model.dart';

class TaskController extends GetxController{
  final taskCollection = FirebaseFirestore.instance.collection(Collectons.Tasks);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<bool> addNewTask(TaskModel model) async {
    try {
      await taskCollection.add(
        model.toFireStore(model.title, model.description, model.deadline),
      );
      update();
      return true; // success
    } catch (e) {
      print("Add Task Error: $e");
      return false; // failed
    }
  }

  Future<bool> deleteTask(String id) async {
    _isLoading = true;
    update();
    try {
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