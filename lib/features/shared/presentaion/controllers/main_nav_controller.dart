import 'package:get/get.dart';

class MainNavControler extends GetxController{

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changeIndex(int index){
    if(_selectedIndex == index){
      return;
    }
    _selectedIndex = index;
    update();

  }

  void backToHome(){
    _selectedIndex = 0;
  }

}