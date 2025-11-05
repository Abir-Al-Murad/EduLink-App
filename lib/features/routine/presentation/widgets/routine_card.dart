import 'package:flutter/material.dart';

import '../../data/models/routine_model.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    super.key,
    required this.item,
    required this.index,
  });
  final int index;
  final RoutineModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin:
      const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor:
          Colors.blueAccent.withOpacity(0.8),
          child: Text(
            "${index + 1}",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.course,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Time: ${item.time}\nRoom: ${item.room}\nTeacher: ${item.teacher}",
            style: const TextStyle(height: 1.5),
          ),
        ),
      ),
    );
  }
}
