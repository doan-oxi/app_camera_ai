import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

mixin AILeaveTimeLogic on SuperPutController<AIDetectSettingState> {
  TextEditingController leaveTimeController = TextEditingController();

  @override
  void initPut() {
    lazyPut<AILeaveTimeLogic>(this);
    super.initPut();
  }

  void initLeaveTime() {
    state!.leaveTime.value = Manager()
            .getDeviceManager()
            ?.deviceModel
            ?.offPostMonitorModel
            .value
            ?.leavetime
            .value ??
        30;
  }

  void setLeaveTime() async {
    String seconds = leaveTimeController.text.trim();
    if (seconds.length == 0) {
      EasyLoading.showToast("请输入时间");
      return;
    }
    int second = int.parse(seconds);
    if (second < 30) {
      second = 30;
    } else if (second > 3600) {
      second = 3600;
    }
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (model == null) return;
    int? tempTime = model.offPostMonitorModel.value?.leavetime.value;
    model.offPostMonitorModel.value?.leavetime.value = second;
    var config = model.offPostMonitorModel.value?.toJsonString();
    if (config != null) {
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.offPostMonitor, config);
      if (!bl) {
        model.offPostMonitorModel.value?.leavetime.value = tempTime ?? 30;
      } else {
        state!.leaveTime.value = second;
        EasyLoading.showToast("设置成功！");
        Get.back();
      }
    }
  }
}
