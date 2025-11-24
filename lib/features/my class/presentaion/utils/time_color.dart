import 'package:flutter/material.dart';

Color getTimeColor(DateTime? uploadedAt) {
  if (uploadedAt == null) return Colors.grey;
  final now = DateTime.now();
  final difference = now.difference(uploadedAt);

  if (difference.inHours < 1) return Colors.green;
  if (difference.inHours < 24) return Colors.blue;
  return Colors.orange;
}