import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universityclassroommanagement/features/home/presentation/screens/home_screen.dart';
import 'package:universityclassroommanagement/features/notice/presentation/screens/notice_screen.dart';
import 'package:universityclassroommanagement/features/profile/presentaion/screens/profile_screen.dart';
import 'package:universityclassroommanagement/features/routine/presentation/screens/routine_screen.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/controllers/main_nav_controller.dart';

class BottomNavHolder extends StatefulWidget {
  const BottomNavHolder({super.key});
  static const name = '/bottom-holder';

  @override
  State<BottomNavHolder> createState() => _BottomNavHolderState();
}

class _BottomNavHolderState extends State<BottomNavHolder> {
  final List<Widget> _screens = [
    HomeScreen(),
    NoticeScreen(),
    RoutineScreen(),
    ProfileScreen(),
  ];
  final MainNavControler mainNavControler = Get.find<MainNavControler>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainNavControler>(
      builder: (controller) {
        return Scaffold(
          body: _screens[controller.selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.selectedIndex,
            onDestinationSelected: controller.changeIndex,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),NavigationDestination(
                icon: Icon(Icons.announcement_outlined),
                label: 'Notice',
              ),NavigationDestination(
                icon: Icon(Icons.schedule),
                label: 'Routine',
              ),NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        );
      }
    );
  }
}
