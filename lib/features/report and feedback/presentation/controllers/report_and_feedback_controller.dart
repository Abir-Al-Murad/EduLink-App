import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReportAndFeedBackController extends GetxController{
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> addReportAndFeedback(String email,String name,String report)async{
    _isLoading = true;
    bool isSuccess = false;
    update();

    try{
      await FirebaseFirestore.instance.collection('reports').add({
        'email':email,
        'name':name,
        'report':report,
        'submittedAt':Timestamp.now(),
      });
      isSuccess  = true;
      _errorMessage = null;
    }catch(e){
      _errorMessage = 'Failed to submit your report';
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }
}