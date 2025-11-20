import 'package:flutter/material.dart';

class TabCard extends StatelessWidget {
  const TabCard({
    super.key,
    required this.selectedTask,
    required this.title,
  });

  final bool selectedTask;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        style: TextStyle(
          color: selectedTask
              ? Colors.white
              : Colors.black87,
          fontWeight: selectedTask
              ? FontWeight.bold
              : FontWeight.w500,
          fontSize: selectedTask? 15 : 14,
        ),
        child:  Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
