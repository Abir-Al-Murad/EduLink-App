import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class TaskSelector extends StatefulWidget {
  const TaskSelector({super.key,required this.onSelect});

  final Function(int) onSelect;


  @override
  State<TaskSelector> createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> {

  int selectedTask = 0;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTask = 0;
                  widget.onSelect(0);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTask == 0
                      ? AppColors.royalThemeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Uncompleted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTask == 0
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: selectedTask == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.onSelect(1);
                  selectedTask = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTask == 1
                      ? AppColors.royalThemeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Completed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTask == 1
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: selectedTask == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
