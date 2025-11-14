import 'package:flutter/material.dart';
import '../../../shared/presentaion/widgets/format_Date.dart';
import '../../data/models/notice_model.dart';
import '../widgets/linkify_description.dart';

class NoticeDetailsScreen extends StatefulWidget {
  const NoticeDetailsScreen({super.key, required this.model});
  final NoticeModel model;

  static const name = '/notice-details';

  @override
  State<NoticeDetailsScreen> createState() => _NoticeDetailsScreenState();
}

class _NoticeDetailsScreenState extends State<NoticeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.model.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Published on: ${formatDate(widget.model.createdAt)}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Divider(height: 30, thickness: 1),
              LinkifyDescription(description: widget.model.description),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

