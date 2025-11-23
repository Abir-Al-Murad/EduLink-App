import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openFilePreview(BuildContext context,File? pickedFile,String? url) async {
  if (pickedFile == null && url == null) return;

  if(url !=null){
    await launchUrl(Uri.parse(url));
  }else {
    final ext = pickedFile!
        .path
        .split('.')
        .last
        .toLowerCase();
    print(ext);

    // Show image in app
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  // Image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      child: Image.file(
                        pickedFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Close button
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
      return;
    }

    // Open other files with external app
    try {
      final result = await OpenFilex.open(pickedFile.path);

      if (result.type == ResultType.noAppToOpen) {
        Get.snackbar(
          'No App Found',
          'Install an app to open .${ext} files',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result.type == ResultType.permissionDenied) {
        Get.snackbar(
          'Permission Denied',
          'Please grant storage permission',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result.type == ResultType.fileNotFound) {
        Get.snackbar(
          'File Not Found',
          'The file may have been moved or deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Error opening file: $e");
      Get.snackbar('Error', 'Failed to open file');
    }
  }
}
