import 'package:flutter/material.dart';
import 'package:universityclassroommanagement/app/app_colors.dart';

class IconFilledButton extends StatelessWidget {
  const IconFilledButton({super.key, required this.onTap, required this.title});
  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded),
        label:  Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.themeColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    )
    ;
  }
}
