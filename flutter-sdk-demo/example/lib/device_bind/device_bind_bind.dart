import 'package:get/get.dart';

import 'device_bind_logic.dart';

class DeviceBindBind implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceBindLogic>(DeviceBindLogic());
  }
}
