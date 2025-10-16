import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AISensitivityLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AISensitivityLogic>(this);
    super.initPut();
  }

  int getSensitivityValue() {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return -1;
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        return deviceModel.areaIntrusionModel.value?.sensitive.value ?? -1;
      case AiType.personStay:
        return deviceModel.personStayModel.value?.sensitive.value ?? -1;
      case AiType.illegalParking:
        return deviceModel.illegalParkingModel.value?.sensitive.value ?? -1;
      case AiType.crossBorder:
        return deviceModel.crossBorderModel.value?.sensitive.value ?? -1;
      case AiType.offPostMonitor:
        return deviceModel.offPostMonitorModel.value?.sensitive.value ?? -1;
      case AiType.carRetrograde:
        return deviceModel.carRetrogradeModel.value?.sensitive.value ?? -1;
      case AiType.packageDetect:
        return deviceModel.packageDetectModel.value?.sensitive.value ?? -1;
      case AiType.fireSmokeDetect:
        return deviceModel.fireSmokeDetectModel.value?.sensitive.value ?? -1;
    }
    return -1;
  }

  void controlSensitivity(int value, AiType type) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (model == null) return;

    var temp;
    switch (type) {
      case AiType.areaIntrusion:
        temp = model.areaIntrusionModel.value?.sensitive.value;
        break;
      case AiType.personStay:
        temp = model.personStayModel.value?.sensitive.value;
        break;
      case AiType.illegalParking:
        temp = model.illegalParkingModel.value?.sensitive.value;
        break;
      case AiType.offPostMonitor:
        temp = model.offPostMonitorModel.value?.sensitive.value;
        break;
      case AiType.carRetrograde:
        temp = model.carRetrogradeModel.value?.sensitive.value;
        break;
      case AiType.crossBorder:
        temp = model.crossBorderModel.value?.sensitive.value;
        break;
      case AiType.packageDetect:
        temp = model.packageDetectModel.value?.sensitive.value;
        break;
      case AiType.fireSmokeDetect:
        temp = model.fireSmokeDetectModel.value?.sensitive.value;
        break;
      default:
        break;
    }

    switch (type) {
      case AiType.areaIntrusion:
        model.areaIntrusionModel.value?.sensitive.value = value;
        var config = model.areaIntrusionModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.areaIntrusionModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.personStay:
        model.personStayModel.value?.sensitive.value = value;
        var config = model.personStayModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.personStayModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.illegalParking:
        model.illegalParkingModel.value?.sensitive.value = value;
        var config = model.illegalParkingModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.illegalParkingModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.crossBorder:
        model.crossBorderModel.value?.sensitive.value = value;
        var config = model.crossBorderModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.crossBorderModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.offPostMonitor:
        model.offPostMonitorModel.value?.sensitive.value = value;
        var config = model.offPostMonitorModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.offPostMonitorModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.carRetrograde:
        model.carRetrogradeModel.value?.sensitive.value = value;
        var config = model.carRetrogradeModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.carRetrogradeModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.packageDetect:
        model.packageDetectModel.value?.sensitive.value = value;
        var config = model.packageDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.packageDetectModel.value?.sensitive.value = temp;
          }
        }
        break;
      case AiType.fireSmokeDetect:
        model.fireSmokeDetectModel.value?.sensitive.value = value;
        var config = model.fireSmokeDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.fireSmokeDetectModel.value?.sensitive.value = temp;
          }
        }
        break;
    }
    state!.sensitivityFlag.value++;
  }
}
