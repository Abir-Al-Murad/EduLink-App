import 'package:flutter/material.dart';
import 'package:EduLink/features/task/presentation/widgets/task_tile.dart';

import '../../../shared/presentaion/widgets/show_dialog.dart';
import '../../data/model/task_model.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key,required this.listOfData,required this.refresh});
  final List<TaskModel> listOfData;

  final Function(bool) refresh;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {

  @override
  Widget build(BuildContext context) {
    if(widget.listOfData.isEmpty){
      return SizedBox(
        height: 200,
        child: const Center(
          child: Text("List is empty"),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.listOfData.length,
      itemBuilder: (context, index) {
        final item = widget.listOfData[index];
        return GestureDetector(
          onLongPress: () {
            buildShowDialog(context, item);
          },
          child: TaskTile(
            index: index,
            taskModel: item,
            refresh: (value) {
              if (value == true) {
                widget.refresh(true);
              }
            },
          ),
        );
      },
    );
  }
}
