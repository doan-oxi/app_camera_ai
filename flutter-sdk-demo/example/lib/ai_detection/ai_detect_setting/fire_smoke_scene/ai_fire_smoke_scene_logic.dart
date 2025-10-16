import 'package:vsdk_example/utils/device_manager.dart';

import '../../../model/device_model.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

mixin AIFireSmokeSceneLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIFireSmokeSceneLogic>(this);
    super.initPut();
  }

  initFireSmokeScene() {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) {
      return;
    }
    state!.fireSmokeScene.value =
        deviceModel.fireSmokeDetectModel.value?.firePlace.value ?? 0;
  }

  setFireSmokeScene(int index) async {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) {
      return;
    }
    var config;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    deviceModel.fireSmokeDetectModel.value?.firePlace.value = index;
    config = deviceModel.fireSmokeDetectModel.value?.toJsonString();
    if (config != null) {
      bool bl = await aiDetectionLogic.setAiDetectData(
          AiType.fireSmokeDetect, config);
      if (!bl) {
        deviceModel.fireSmokeDetectModel.value?.firePlace.value =
            index == 0 ? 1 : 0;
      } else {
        state!.fireSmokeScene.value = index;
        EasyLoading.showToast("设置成功！");
        Get.back();
      }
    }
  }
}
