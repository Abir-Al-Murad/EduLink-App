import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../shared/presentaion/widgets/format_Date.dart';
import '../../data/models/class_room_model.dart';

class ClassroomCard extends StatelessWidget {
  final ClassRoomModel classroom;
  final VoidCallback onTap;

  const ClassroomCard({
    Key? key,
    required this.classroom,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.themeColor.withOpacity(0.1),
                AppColors.mediumThemeColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              // Classroom Icon/Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.royalThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // Classroom Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Classroom Name
                    Text(
                      classroom.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.themeColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Subject
                    Text(
                      classroom.subject,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Metadata Row
                    Row(
                      children: [
                        // Students Count
                        _buildInfoChip(
                          icon: Icons.people_rounded,
                          text: '${classroom.students.length} students',
                        ),

                        const SizedBox(width: 12),

                        // Created Date
                        _buildInfoChip(
                          icon: Icons.calendar_today_rounded,
                          text: formatDate(classroom.createdAt),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.mediumThemeColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mediumThemeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.royalThemeColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.royalThemeColor,
            ),
          ),
        ],
      ),
    );
  }

}