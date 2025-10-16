import 'package:get/get.dart';

import 'ai_detection_logic.dart';

class AIDetectionBind implements Bindings {
  @override
  void dependencies() {
    Get.put<AIDetectionLogic>(AIDetectionLogic());
  }
}
