import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/features/classroom/data/models/class_room_model.dart';

Future<bool> checkAdmin(String classId, String uid) async {
  try {
    final classDoc = await FirebaseFirestore.instance
        .collection(Collectons.classes)
        .doc(classId)
        .get();

    if (!classDoc.exists || classDoc.data() == null) {
      print("⚠️ Class not found: $classId");
      return false;
    }

    final model = ClassRoomModel.fromFireStore(classDoc.data()!, classDoc.id);
    return model.admins.contains(uid);
  } catch (e) {
    print("❌ Error checking admin status: $e");
    return false;
  }
}
