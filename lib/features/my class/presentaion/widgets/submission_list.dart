import 'package:EduLink/features/task/data/model/attachments_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/file_color.dart';
import '../utils/file_icon.dart';
import '../utils/format_time.dart';
import '../utils/time_color.dart';
import '../utils/time_status.dart';

class SubmissionList extends StatelessWidget {
  const SubmissionList({
    super.key,
    required this.attachments,
    required this.submissionCount,
    required this.deadline,
  });

  final List<AttachmentsModel> attachments;
  final int submissionCount;
  final Timestamp deadline; // Add deadline

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              "No submissions yet",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12, left: 8),
            child: Text(
              "Recent Submissions ($submissionCount)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final file = attachments[index];
                final uploadedAt = file.uploadedAt.toDate();
                final fileName = file.fileName;
                final fileUrl = file.fileUrl;
                final studentName = file.studentName;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: getFileColor(fileName),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          getFileIcon(fileName),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        fileName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            studentName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                formatTime(uploadedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (_isLateSubmission(uploadedAt, deadline.toDate()))
                              SizedBox(width: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: getTimeColor(uploadedAt, deadline: deadline.toDate()),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  getTimeStatus(uploadedAt, deadline: deadline.toDate()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Deadline: ${_formatDeadline(deadline.toDate())}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getDeadlineColor(deadline.toDate()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.blue.shade600,
                          size: 18,
                        ),
                      ),
                      onTap: () async {
                        final url = Uri.parse(fileUrl);
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// FIXED: Compare with deadline, not assigned date
bool _isLateSubmission(DateTime uploadedAt, DateTime deadline) {
  return uploadedAt.isAfter(deadline);
}

String _getLateDuration(DateTime uploadedAt, DateTime deadline) {
  final lateDuration = uploadedAt.difference(deadline);

  if (lateDuration.inDays > 0) {
    return "${lateDuration.inDays}d LATE";
  } else if (lateDuration.inHours > 0) {
    return "${lateDuration.inHours}h LATE";
  } else {
    return "${lateDuration.inMinutes}m LATE";
  }
}

String _formatDeadline(DateTime deadline) {
  final now = DateTime.now();

  if (deadline.isBefore(now)) {
    return "Passed ${DateFormat('MMM dd').format(deadline)}";
  } else {
    final difference = deadline.difference(now);
    if (difference.inDays > 0) {
      return "in ${difference.inDays} days";
    } else if (difference.inHours > 0) {
      return "in ${difference.inHours} hours";
    } else {
      return "Today";
    }
  }
}

Color _getDeadlineColor(DateTime deadline) {
  final now = DateTime.now();

  if (deadline.isBefore(now)) {
    return Colors.red.shade600; // Deadline passed
  } else if (deadline.difference(now).inDays <= 1) {
    return Colors.orange.shade600; // Due soon (within 24 hours)
  } else {
    return Colors.green.shade600; // Still time left
  }
}

// Updated helper methods with deadline parameter
Color getTimeColor(DateTime uploadedAt, {DateTime? deadline}) {
  // If deadline is provided and submission is late, return red
  if (deadline != null && uploadedAt.isAfter(deadline)) {
    return Colors.red.shade500;
  }

  final now = DateTime.now();
  final difference = now.difference(uploadedAt);

  if (difference.inHours < 1) return Colors.green;
  if (difference.inHours < 24) return Colors.blue;
  return Colors.orange;
}

String getTimeStatus(DateTime uploadedAt, {DateTime? deadline}) {
  // If deadline is provided and submission is late
  if (deadline != null && uploadedAt.isAfter(deadline)) {
    final lateBy = uploadedAt.difference(deadline);
    if (lateBy.inDays > 0) return "${lateBy.inDays}d LATE";
    if (lateBy.inHours > 0) return "${lateBy.inHours}h LATE";
    return "${lateBy.inMinutes}m LATE";
  }

  final now = DateTime.now();
  final difference = now.difference(uploadedAt);

  if (difference.inMinutes < 1) return "NEW";
  if (difference.inHours < 1) return "RECENT";
  if (difference.inHours < 24) return "TODAY";
  return "EARLIER";
}