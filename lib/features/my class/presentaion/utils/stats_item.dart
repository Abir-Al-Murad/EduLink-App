import 'package:flutter/material.dart';


Widget buildStatItem(IconData icon, String label, String value, Color color) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
