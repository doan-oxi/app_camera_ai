import 'package:get/get.dart';

import 'ai_detect_setting_logic.dart';

class AIDetectSettingBind implements Bindings {
  @override
  void dependencies() {
    Get.put<AIDetectSettingLogic>(AIDetectSettingLogic());
  }
}
