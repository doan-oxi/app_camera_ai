import 'package:get/get.dart';
import 'home_logic.dart';

class HomeBind implements Bindings {
  @override
  void dependencies() {
    Get.put<HomeLogic>(HomeLogic());
  }

  void dispose() {
    Get.delete<HomeLogic>();
  }
}
