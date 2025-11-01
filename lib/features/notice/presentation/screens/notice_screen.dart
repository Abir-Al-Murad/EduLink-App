import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:universityclassroommanagement/features/notice/presentation/screens/add_notice_screen.dart';
import 'package:universityclassroommanagement/features/notice/presentation/screens/notice_details_screen.dart';
import 'package:universityclassroommanagement/features/notice/presentation/widgets/linkify_description.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/widgets/format_Date.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/notice_model.dart';
import 'package:universityclassroommanagement/app/collections.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<List<NoticeModel>>(
        future: FirebaseFirestore.instance
            .collection(Collectons.announcement)
            .orderBy('createdAt', descending: true)
            .get()
            .then((snapshot) => snapshot.docs
            .map((e) => NoticeModel.fromFireStore(e.data()))
            .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching notices"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notices found"));
          }

          final notices = snapshot.data!;
          return Column(
            children: [
              SizedBox(height: 10,),
              FilledButton(onPressed: ()async{
                final result = await Navigator.pushNamed(context, AddNotice.name);
                if(result == true){
                  setState(() {

                  });
                }
              }, child: Text("Add Notice")),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Published on: ${formatDate(notice.createdAt)}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinkifyDescription(description: notice.description),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, NoticeDetailsScreen.name,arguments: notice);
                                },
                                child: const Text("Read More"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
