import 'package:get/get.dart';

import 'area_draw_logic.dart';

class AIAreaDrawBind implements Bindings {
  @override
  void dependencies() {
    Get.put<AiAreaDrawLogic>(AiAreaDrawLogic());
  }
}
