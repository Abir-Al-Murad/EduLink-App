import 'package:EduLink/core/services/auth_controller.dart';
import 'package:EduLink/core/services/connectivity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:EduLink/app/collections.dart';
import 'package:EduLink/core/services/local_db_helper.dart';
import 'package:EduLink/features/classroom/data/models/class_room_model.dart';

Future<void> checkAdmin(String classId, String uid) async {

  if(!ConnectivityService().isOffline.value){
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(classId)
          .get();

      if (!classDoc.exists || classDoc.data() == null) {
        print("⚠️ Class not found: $classId");
        return ;
      }

      final model = ClassRoomModel.fromFireStore(classDoc.data()!, classDoc.id);
      AuthController.isAdmin =  model.admins.contains(uid);
    } catch (e) {
      print("❌ Error checking admin status: $e");
    }
  }else{
    try {
      LocalDbHelper dbHelper = LocalDbHelper.getInstance();
      final model = await dbHelper.getClass(classId);
      print(model);
      AuthController.isAdmin = model!.admins.contains(uid);
    } catch (e) {
      print("❌ Error checking admin status from local db: $e");

    }

  }


}
