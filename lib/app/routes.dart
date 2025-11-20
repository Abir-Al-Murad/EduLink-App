import 'package:EduLink/features/task/data/model/task_model.dart';
import 'package:EduLink/features/task/presentation/screens/task_details_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentaion/screens/signin_screen.dart';
import '../features/auth/presentaion/screens/signup_screen.dart';
import '../features/classroom/presentation/screens/my_classrooms_screen.dart';
import '../features/task/presentation/screens/add_task_screen.dart';
import '../features/task/presentation/screens/task_screen.dart';
import '../features/notice/data/models/notice_model.dart';
import '../features/notice/presentation/screens/add_notice_screen.dart';
import '../features/notice/presentation/screens/notice_details_screen.dart';
import '../features/profile/presentaion/screens/members_list_screen.dart';
import '../features/report and feedback/presentation/screens/report_and_feedback.dart';
import '../features/routine/presentation/screens/add_routine_screen.dart';
import '../features/shared/presentaion/screens/bottom_nav_holder.dart';

MaterialPageRoute onGenerateRoute(RouteSettings settings){
  late Widget screen;
  if(settings.name == AddTaskScreen.name){
    screen = AddTaskScreen();
  }else if(settings.name == AddNotice.name){
    screen = AddNotice();
  }else if(settings.name == ReportAndFeedback.name){
    screen = ReportAndFeedback();
  }else if(settings.name == MembersListScreen.name){
    screen = MembersListScreen();
  }else if(settings.name == SigninScreen.name){
    screen = SigninScreen();
  }else if(settings.name == MyClassrooms.name){
    screen = MyClassrooms();
  }else if(settings.name == TaskScreen.name){
    screen = TaskScreen();
  }else if(settings.name == BottomNavHolder.name){
    screen = BottomNavHolder();
  }else if(settings.name == SignupScreen.name){
    screen = SignupScreen();
  }else if(settings.name == NoticeDetailsScreen.name){
    final model = settings.arguments as NoticeModel;
    screen = NoticeDetailsScreen(model: model);
  }else if(settings.name == AddRoutineScreen.name){
    final day = settings.arguments as String;
    screen = AddRoutineScreen(day: day);
  }else if(settings.name == TaskDetailsScreen.name){
    final taskModel = settings.arguments as TaskModel;
    screen = TaskDetailsScreen(taskModel: taskModel);
  }
  return MaterialPageRoute(builder: (context)=>screen);
}