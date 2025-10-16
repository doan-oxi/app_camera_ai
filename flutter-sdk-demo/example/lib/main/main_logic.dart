import 'package:flutter/cupertino.dart';
import 'package:vsdk_example/utils/super_put_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'main_state.dart';

class MainLogic extends SuperPutController<MainState> {
  TextEditingController idController = TextEditingController();
  TextEditingController pswController = TextEditingController();

  MainLogic() {
    value = MainState();
  }

  @override
  void onInit() {
    super.onInit();
  }

  saveDeviceInfo() {
    if (idController.text.length < 1) {
      EasyLoading.showToast("请输入设备id");
      return;
    }
    state!.uid = idController.text;
    if (pswController.text.isEmpty) {
      state!.psw = "888888";
    } else {
      state!.psw = pswController.text;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
