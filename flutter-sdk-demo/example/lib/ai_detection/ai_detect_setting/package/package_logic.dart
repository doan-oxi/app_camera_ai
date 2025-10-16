import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AIPackageLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIPackageLogic>(this);
    super.initPut();
  }

  ///包裹开关设置
  void setSwitch(bool value, int index) async {
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (index == 0) {
      ///包裹出现
      model.packageDetectModel.value?.appearEnable.value = value ? 1 : 0;
      var config = model.packageDetectModel.value?.toJsonString();
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.packageDetect, config!);
      if (!bl) {
        model.packageDetectModel.value?.appearEnable.value = value ? 0 : 1;
      }
    } else if (index == 1) {
      ///包裹消失
      model.packageDetectModel.value?.disappearEnable.value = value ? 1 : 0;
      var config = model.packageDetectModel.value?.toJsonString();
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.packageDetect, config!);
      if (!bl) {
        model.packageDetectModel.value?.disappearEnable.value = value ? 0 : 1;
      }
    } else {
      ///包裹滞留
      model.packageDetectModel.value?.stayEnable.value = value ? 1 : 0;
      var config = model.packageDetectModel.value?.toJsonString();
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.packageDetect, config!);
      if (!bl) {
        model.packageDetectModel.value?.stayEnable.value = value ? 0 : 1;
      }
    }
    setIsShow(index);
    setIsOpen();
  }

  setIsShow(int index) {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (index == 0) {
      if (model.packageDetectModel.value?.appearEnable.value == 1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    } else if (index == 1) {
      if (model.packageDetectModel.value?.disappearEnable.value == 1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    } else if (index == 2) {
      if (model.packageDetectModel.value?.stayEnable.value == 1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    }
  }

  setIsOpen() {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (model.packageDetectModel.value?.appearEnable.value == 0 &&
        model.packageDetectModel.value?.disappearEnable.value == 0 &&
        model.packageDetectModel.value?.stayEnable.value == 0) {
      state!.isOpen.value = false;
    }
  }
}
