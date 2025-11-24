import 'package:EduLink/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'tab_card.dart';

class TaskSelector extends StatefulWidget {
  const TaskSelector({super.key, required this.onSelect});

  final Function(int) onSelect;

  @override
  State<TaskSelector> createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> {
  int selectedTask = 0;

  void _onTaskSelected(int index) {
    if (selectedTask == index) return;

    setState(() {
      selectedTask = index;
      widget.onSelect(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // UNCOMPLETED
          Expanded(
            child: GestureDetector(
              onTap: () => _onTaskSelected(0),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedTask == 0 ? AppColors.themeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: TabCard(
                  selectedTask: selectedTask == 0,
                  title: 'Uncompleted',
                ),
              ),
            ),
          ),

          // COMPLETED
          Expanded(
            child: GestureDetector(
              onTap: () => _onTaskSelected(1),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedTask == 1 ? AppColors.themeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: TabCard(
                  selectedTask: selectedTask == 1,
                  title: 'Completed',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
