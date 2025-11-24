import 'package:flutter/material.dart';

Color getFileColor(String fileName) {
  if (fileName.toLowerCase().contains('.pdf')) return Colors.red;
  if (fileName.toLowerCase().contains('.doc')) return Colors.blue;
  if (fileName.toLowerCase().contains('.ppt')) return Colors.orange;
  if (fileName.toLowerCase().contains('.xls')) return Colors.green;
  return Colors.purple;
}