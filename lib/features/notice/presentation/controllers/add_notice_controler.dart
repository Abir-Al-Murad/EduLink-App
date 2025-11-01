import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/features/notice/data/models/notice_model.dart';

class AddNoticeController extends GetxController{
  bool _isLoading = false;
  bool  get isLoading => _isLoading;

  final firestoreCollection = FirebaseFirestore.instance.collection(Collectons.announcement);

  Future<bool> addNotice(NoticeModel model)async{
    bool isSuccess = false;
    _isLoading = true;
    update();
    try{
     await firestoreCollection.add(
        model.toFireStore(model.title, model.description),
      );
      isSuccess = true;
    }catch(e){
      isSuccess = false;
    }
    _isLoading = false;
    update();
    return isSuccess;
  }
}