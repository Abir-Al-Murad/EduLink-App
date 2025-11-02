import 'package:flutter/material.dart';

class ElelvetedButtonWithLogo extends StatelessWidget {
  const ElelvetedButtonWithLogo({
    super.key,
    required this.onTap, required this.titleText, required this.image
  });

  final VoidCallback onTap;
  final String titleText;
  final String image;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: SizedBox(
        width: 24,
        height: 24,
        child: Image.asset(
          image,
          fit: BoxFit.contain,
        ),
      ),
      label: Text(
        titleText,
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 1,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
