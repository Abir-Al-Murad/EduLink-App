import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universityclassroommanagement/app/collections.dart';
import 'package:universityclassroommanagement/core/services/auth_controller.dart';
import 'package:universityclassroommanagement/features/classroom/data/models/class_room_model.dart';
import 'package:universityclassroommanagement/features/profile/data/models/user_model.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/utils/check_admin.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({super.key});
  static const name = '/member-list-screen';

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  List<UserModel> members = [];
  List<UserModel> adminsIdList = [];
  bool _isLoading = true;

  /// Fetch all members & admin list
  Future<void> fetchMembers() async {
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection(Collectons.classes)
          .doc(AuthController.classDocId)
          .get();

      final classData = ClassRoomModel.fromFireStore(classDoc.data()!, classDoc.id);

      final studentIds = classData.students;
      final adminIds = classData.admins;

      // Fetch all user documents matching studentIds
      if (studentIds.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection(Collectons.users)
            .where("uid", whereIn: studentIds)
            .get();

        members = usersSnapshot.docs
            .map((doc) => UserModel.fromFireStore(doc.data()))
            .toList();
      }
      if (adminIds.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection(Collectons.users)
            .where("uid", whereIn: adminIds)
            .get();

        adminsIdList = usersSnapshot.docs
            .map((doc) => UserModel.fromFireStore(doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint("❌ Error fetching members: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Number of Admins: ${adminsIdList.length}");
    debugPrint("Number of members: ${members.length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Members"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text("No members found"))
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final user = members[index];
          bool isAdmin = false;
          if(adminsIdList.isNotEmpty){
            for(int i =0;i<adminsIdList.length;i++){
              if (adminsIdList[i].uid == user.uid) {
                isAdmin = true;
                break;
              }else{
                isAdmin = false;
              }
            }
          }
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl!),
            ),
            title: Text(user.name!),
            subtitle: Text(user.email!),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.blue.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? "Admin" : "Member",
                style: TextStyle(
                  color: isAdmin ? Colors.blue.shade900 : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
