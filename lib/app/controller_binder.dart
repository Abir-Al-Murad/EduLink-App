import 'package:get/get.dart';
import 'package:universityclassroommanagement/features/home/presentation/controllers/task_controller.dart';
import 'package:universityclassroommanagement/features/notice/presentation/controllers/add_notice_controler.dart';
import 'package:universityclassroommanagement/features/shared/presentaion/controllers/main_nav_controller.dart';

class ControllerBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(MainNavControler());
    Get.put(TaskController());
    Get.put(AddNoticeController());

  }

}