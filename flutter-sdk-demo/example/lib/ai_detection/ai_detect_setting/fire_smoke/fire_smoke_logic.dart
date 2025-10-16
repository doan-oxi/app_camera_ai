import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AIFireSmokeLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIFireSmokeLogic>(this);
    super.initPut();
  }

  ///火灾烟雾开关设置
  void setFireSmokeSwitch(bool value, int index) async {
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (index == 0) {
      ///火灾监测
      model.fireSmokeDetectModel.value?.fireEnable.value = value ? 1 : 0;
      var config = model.fireSmokeDetectModel.value?.toJsonString();
      bool bl = await aiDetectionLogic.setAiDetectData(
          AiType.fireSmokeDetect, config!);
      if (!bl) {
        model.fireSmokeDetectModel.value?.fireEnable.value = value ? 0 : 1;
      }
    } else if (index == 1) {
      ///烟雾监测
      model.fireSmokeDetectModel.value?.smokeEnable.value = value ? 1 : 0;
      var config = model.fireSmokeDetectModel.value?.toJsonString();
      bool bl = await aiDetectionLogic.setAiDetectData(
          AiType.fireSmokeDetect, config!);
      if (!bl) {
        model.fireSmokeDetectModel.value?.smokeEnable.value = value ? 0 : 1;
      }
    }
    setShow(index);
    _setIsOpen();
  }

  setShow(int index) {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (index == 0) {
      if (model.fireSmokeDetectModel.value?.fireEnable.value == 1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    } else if (index == 1) {
      if (model.fireSmokeDetectModel.value?.smokeEnable.value == 1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    }
  }

  _setIsOpen() {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (model.fireSmokeDetectModel.value?.fireEnable.value == 0 &&
        model.fireSmokeDetectModel.value?.smokeEnable.value == 0) {
      state!.isOpen.value = false;
    }
  }
}
