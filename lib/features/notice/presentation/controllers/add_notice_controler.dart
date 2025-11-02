import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/features/notice/data/models/notice_model.dart';

import '../../../../core/services/auth_controller.dart';

class AddNoticeController extends GetxController{
  bool _isLoading = false;
  bool  get isLoading => _isLoading;


  Future<bool> addNotice(NoticeModel model,String classDocId)async{
    print('A Notice is Posted to ${AuthController.classDocId}');
    bool isSuccess = false;
    _isLoading = true;
    update();
    try{
      final firestoreCollection = FirebaseFirestore.instance.collection(Collectons.classes).doc(classDocId).collection(Collectons.notice);

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