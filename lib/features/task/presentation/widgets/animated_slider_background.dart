import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class AnimatedSliderBackground extends StatelessWidget {
  const AnimatedSliderBackground({
    super.key,
    required Animation<double> slideAnimation,
    required this.selectedTask,
    required Animation<double> scaleAnimation,
  }) : _slideAnimation = slideAnimation, _scaleAnimation = scaleAnimation;

  final Animation<double> _slideAnimation;
  final int selectedTask;
  final Animation<double> _scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: selectedTask == 0
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.royalThemeColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.royalThemeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
