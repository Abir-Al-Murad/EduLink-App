import 'package:EduLink/features/my%20class/presentaion/screens/my_class_screen.dart';
import 'package:EduLink/features/task/presentation/screens/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EduLink/features/notice/presentation/screens/notice_screen.dart';
import 'package:EduLink/features/routine/presentation/screens/routine_screen.dart';
import 'package:EduLink/features/shared/presentaion/controllers/main_nav_controller.dart';

import '../../../../app/app_colors.dart';
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
    TaskScreen(),
    NoticeScreen(),
    RoutineScreen(),
    MyClassScreen(),
  ];
  final MainNavControler mainNavControler = Get.find<MainNavControler>();

  @override
  void initState() {
    checkAdmin(AuthController.classDocId!, AuthController.user!.uid);
    mainNavControler.backToHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainNavControler>(
      builder: (controller) {
        return PopScope(
          canPop: controller.selectedIndex == 0,
          onPopInvoked: (didPop){
            if(!didPop){
              if(controller.selectedIndex !=0){
                controller.backToHome();
              }
            }
          },
          child: Scaffold(
            body: _screens[controller.selectedIndex],
              bottomNavigationBar: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated Background
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      width: (MediaQuery.of(context).size.width / 4) - 32, // Adjust for horizontal margin
                      transform: Matrix4.translationValues(
                        (MediaQuery.of(context).size.width / 4) * controller.selectedIndex,
                        0,
                        0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),


                    Row(
                      children: [
                        _buildLiquidItem(0, Icons.task_outlined, Icons.task, 'Task', controller),
                        _buildLiquidItem(1, Icons.announcement_outlined, Icons.announcement, 'Notice', controller),
                        _buildLiquidItem(2, Icons.schedule_outlined, Icons.schedule, 'Routine', controller),
                        _buildLiquidItem(3, Icons.home_work_outlined, Icons.home_work, 'Class', controller),
                      ],
                    ),
                  ],
                ),
              )



          ),
        );
      }
    );
  }
  Widget _buildLiquidItem(int index, IconData icon, IconData activeIcon, String label, MainNavControler controller) {
    bool isSelected = controller.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.themeColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 22,
                  ),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                ),
              ),
              SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? AppColors.themeColor : Colors.grey,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
