import 'package:EduLink/core/services/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:EduLink/features/task/presentation/widgets/task_tile.dart';

import '../../../shared/presentaion/widgets/show_dialog.dart';
import '../../data/model/task_model.dart';
import '../screens/task_details_screen.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key,required this.listOfData,required this.refresh, required this.isListOfCompletedTask});
  final List<TaskModel> listOfData;
  final bool isListOfCompletedTask;

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
          onLongPress: () async{
            if(AuthController.isAdmin){

              final res = await buildShowDialog(context, item);
              if(res == true){
                widget.refresh(true);
              }
            }
          },
          child: GestureDetector(
            onTap: ()async {
              final res = await Navigator.pushNamed(context, TaskDetailsScreen.name,arguments: item);
              if(res == true){
                print("Printing refresh : $res");
                widget.refresh(true);
              }
            },
            child: TaskTile(
              index: index,
              taskModel: item,
              IsCompletedTask: widget.isListOfCompletedTask,
              refresh: (value) {
                if (value == true) {
                  widget.refresh(true);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
