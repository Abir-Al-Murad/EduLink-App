import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NetworkCaller extends GetxController{
  String? errorMessage;
  QuerySnapshot? _snapshot ;
  final fireInstance = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> getRequest(String collection)async{
    bool isSuccess =false;
    _isLoading = true;
    update();
    try {
      final querySnapshot = await fireInstance.collection(collection).get();
      _snapshot = querySnapshot;
      isSuccess = true;
      _isLoading = false;
    } catch (e) {
     isSuccess = false;
    }
    update();
    return isSuccess;

  }
}