import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/features/home/presentation/screens/home_screen.dart';
import 'package:EduLink/features/notice/presentation/screens/notice_screen.dart';
import 'package:EduLink/features/profile/presentaion/screens/profile_screen.dart';
import 'package:EduLink/features/routine/presentation/screens/routine_screen.dart';
import 'package:EduLink/features/shared/presentaion/controllers/main_nav_controller.dart';

import '../../../../core/services/auth_controller.dart';
import '../utils/check_admin.dart';

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
  void initState() {
    checkAdmin(AuthController.classDocId!, AuthController.user!.uid);
    super.initState();
  }

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
