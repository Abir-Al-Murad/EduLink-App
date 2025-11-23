import 'package:flutter/material.dart';

Color getDeadlineIconColor(bool isCompleted,DateTime deadlineDate) {
  if (isCompleted) {
    return Colors.green.shade600;
  }
  final now = DateTime.now();
  final difference = deadlineDate.difference(now).inDays;

  if (difference < 0) {
    return Colors.red.shade600;
  } else if (difference == 0) {
    return Colors.orange.shade600;
  } else if (difference <= 2) {
    return Colors.orange.shade400;
  } else {
    return Colors.green.shade600;
  }
}
