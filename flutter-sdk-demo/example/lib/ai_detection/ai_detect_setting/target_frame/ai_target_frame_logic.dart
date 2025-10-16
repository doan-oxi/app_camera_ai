import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AITargetFrameLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AITargetFrameLogic>(this);
    super.initPut();
  }

  bool getTargetSwitchStatus() {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return false;
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        return deviceModel.areaIntrusionModel.value?.areaframe.value == 1;
      case AiType.personStay:
        return deviceModel.personStayModel.value?.areaframe.value == 1;
      case AiType.illegalParking:
        return deviceModel.illegalParkingModel.value?.areaframe.value == 1;
      case AiType.crossBorder:
        return deviceModel.crossBorderModel.value?.areaframe.value == 1;
      case AiType.offPostMonitor:
        return deviceModel.offPostMonitorModel.value?.areaframe.value == 1;
      case AiType.carRetrograde:
        return deviceModel.carRetrogradeModel.value?.areaframe.value == 1;
      case AiType.packageDetect:
        return deviceModel.packageDetectModel.value?.areaframe.value == 1;
      case AiType.fireSmokeDetect:
        return deviceModel.fireSmokeDetectModel.value?.areaframe.value == 1;
    }
    return false;
  }

  void controlTargetSwitch(bool enable, AiType type) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (model == null) return;
    switch (type) {
      case AiType.areaIntrusion:
        model.areaIntrusionModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.areaIntrusionModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.areaIntrusionModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.personStay:
        model.personStayModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.personStayModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.personStayModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.illegalParking:
        model.illegalParkingModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.illegalParkingModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.illegalParkingModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.crossBorder:
        model.crossBorderModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.crossBorderModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.crossBorderModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.offPostMonitor:
        model.offPostMonitorModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.offPostMonitorModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.offPostMonitorModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.carRetrograde:
        model.carRetrogradeModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.carRetrogradeModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.carRetrogradeModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.packageDetect:
        model.packageDetectModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.packageDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.packageDetectModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.fireSmokeDetect:
        model.fireSmokeDetectModel.value?.areaframe.value = enable ? 1 : 0;
        var config = model.fireSmokeDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.fireSmokeDetectModel.value?.areaframe.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.none:
        // TODO: Handle this case.
        break;
    }
    state!.targetFlag.value++;
  }
}
