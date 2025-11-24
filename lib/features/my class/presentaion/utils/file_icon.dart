import 'package:flutter/material.dart';

IconData getFileIcon(String fileName) {
  if (fileName.toLowerCase().contains('.pdf')) return Icons.picture_as_pdf;
  if (fileName.toLowerCase().contains('.doc')) return Icons.description;
  if (fileName.toLowerCase().contains('.ppt')) return Icons.slideshow;
  if (fileName.toLowerCase().contains('.xls')) return Icons.table_chart;
  return Icons.insert_drive_file;
}