import 'package:flutter/material.dart';
import 'animated_slider_background.dart';
import 'tab_card.dart';

class TaskSelector extends StatefulWidget {
  const TaskSelector({super.key, required this.onSelect});

  final Function(int) onSelect;

  @override
  State<TaskSelector> createState() => _TaskSelectorState();
}

class _TaskSelectorState extends State<TaskSelector> with SingleTickerProviderStateMixin {
  int selectedTask = 0;
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTaskSelected(int index) {
    if (selectedTask == index) return;

    setState(() {
      selectedTask = index;
      widget.onSelect(index);
    });

    _controller.forward(from: 0.0);
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
      child: Stack(
        children: [
          AnimatedSliderBackground(slideAnimation: _slideAnimation, selectedTask: selectedTask, scaleAnimation: _scaleAnimation),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTaskSelected(0),
                  child: TabCard(selectedTask: selectedTask == 0,title: 'Uncompleted',),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTaskSelected(1),
                  child: TabCard(selectedTask: selectedTask == 1,title: 'Completed',),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


