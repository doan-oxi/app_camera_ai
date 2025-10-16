import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import '../utils/super_put_controller.dart';
import 'device_bind_conf.dart';
import 'device_bind_state.dart';

class DeviceBindLogic extends SuperPutController<DeviceBindState> {
  TextEditingController textController = TextEditingController();
  String? uid;

  DeviceBindLogic() {
    value = DeviceBindState();
  }

  @override
  void onInit() {
    var args = Get.arguments;
    print('state.appMode ---onInit');
    if (args is DeviceInfoArgs) {
      uid = args.uid;
    }
    super.onInit();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    print("--------onDelete-------");
    return super.onDelete;
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
