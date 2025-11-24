import 'package:flutter/material.dart';

Color getProgressColor(int percentage) {
  if (percentage >= 75) return Colors.green;
  if (percentage >= 50) return Colors.blue;
  if (percentage >= 25) return Colors.orange;
  return Colors.red;
}
