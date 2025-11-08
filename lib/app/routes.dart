import 'package:flutter/material.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signin_screen.dart';
import 'package:universityclassroommanagement/features/auth/presentaion/screens/signup_screen.dart';
import 'package:universityclassroommanagement/features/classroom/presentation/screens/my_classrooms_screen.dart';
import 'package:universityclassroommanagement/features/home/presentation/screens/add_task_screen.dart';
import 'package:universityclassroommanagement/features/home/presentation/screens/home_screen.dart';
import 'package:universityclassroommanagement/features/notice/data/models/notice_model.dart';
import 'package:universityclassroommanagement/features/notice/presentation/screens/add_notice_screen.dart';
import 'package:universityclassroommanagement/features/notice/presentation/screens/notice_details_screen.dart';
import 'package:universityclassroommanagement/features/profile/presentaion/screens/members_list_screen.dart';
import 'package:universityclassroommanagement/features/report%20and%20feedback/presentation/screens/report_and_feedback.dart';
import 'package:universityclassroommanagement/features/routine/presentation/screens/add_routine_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/screens/bottom_nav_holder.dart';

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
  }else if(settings.name == HomeScreen.name){
    screen = HomeScreen();
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
  }
  return MaterialPageRoute(builder: (context)=>screen);
}