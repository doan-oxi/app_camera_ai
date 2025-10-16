import 'package:vsdk_example/utils/device_manager.dart';

import '../../../model/device_model.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

mixin AIPersonCountLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIPersonCountLogic>(this);
    super.initPut();
  }

  void setCount(int count) async {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) {
      return;
    }
    var temp = deviceModel.offPostMonitorModel.value?.sumperson.value ?? 1;

    var config;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    deviceModel.offPostMonitorModel.value?.sumperson.value = count;
    config = deviceModel.offPostMonitorModel.value?.toJsonString();
    if (config != null) {
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.offPostMonitor, config);
      if (!bl) {
        deviceModel.offPostMonitorModel.value?.sumperson.value = temp;
      } else {
        state!.personCount.value = count;
        EasyLoading.showToast("设置成功！");
        Get.back();
      }
    }
  }

  void initCountState() {
    state!.personCount.value = Manager()
            .getDeviceManager()
            ?.deviceModel
            ?.offPostMonitorModel
            .value
            ?.sumperson
            .value ??
        1;
  }
}
