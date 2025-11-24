import 'package:flutter/material.dart';

import '../utils/progress_color.dart';
import '../utils/stats_item.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.submitted, required this.total, required this.percentage});
  final int submitted;
  final int total;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    getProgressColor(percentage),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "$percentage%",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: getProgressColor(percentage),
                    ),
                  ),
                  Text(
                    "Submitted",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          // Stats Numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem(
                Icons.people_alt_outlined,
                "Total Students",
                "$total",
                Colors.blue.shade600,
              ),
              buildStatItem(
                Icons.assignment_turned_in,
                "Submitted",
                "$submitted",
                Colors.green.shade600,
              ),
              buildStatItem(
                Icons.pending_actions,
                "Pending",
                "${total - submitted}",
                Colors.orange.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
