import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AIFlashLightLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIFlashLightLogic>(this);
    super.initPut();
  }

  bool getSwitchStatus() {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return false;
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        return deviceModel.areaIntrusionModel.value?.lightLed.value == 1;
      case AiType.personStay:
        return deviceModel.personStayModel.value?.lightLed.value == 1;
      case AiType.illegalParking:
        return deviceModel.illegalParkingModel.value?.lightLed.value == 1;
      case AiType.crossBorder:
        return deviceModel.crossBorderModel.value?.lightLed.value == 1;
      case AiType.offPostMonitor:
        return deviceModel.offPostMonitorModel.value?.lightLed.value == 1;
      case AiType.carRetrograde:
        return deviceModel.carRetrogradeModel.value?.lightLed.value == 1;
      case AiType.packageDetect:
        if (state!.currentPackageIndex.value == 0) {
          return deviceModel.packageDetectModel.value?.appearLightLed.value ==
              1;
        }
        if (state!.currentPackageIndex.value == 1) {
          return deviceModel
                  .packageDetectModel.value?.disappearLightLed.value ==
              1;
        }
        if (state!.currentPackageIndex.value == 2) {
          return deviceModel.packageDetectModel.value?.stayLightLed.value == 1;
        }
        return false;
      case AiType.fireSmokeDetect:
        if (state!.currentFireSmokeIndex.value == 0) {
          return deviceModel.fireSmokeDetectModel.value?.fireLightLed.value ==
              1;
        }

        if (state!.currentFireSmokeIndex.value == 1) {
          return deviceModel.fireSmokeDetectModel.value?.smokeLightLed.value ==
              1;
        }
        return false;
    }
    return false;
  }

  void controlFlashLightSwitch(bool enable, AiType type) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (model == null) return;
    switch (type) {
      case AiType.areaIntrusion:
        model.areaIntrusionModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.areaIntrusionModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.areaIntrusionModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.personStay:
        model.personStayModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.personStayModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.personStayModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.illegalParking:
        model.illegalParkingModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.illegalParkingModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.illegalParkingModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.crossBorder:
        model.crossBorderModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.crossBorderModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.crossBorderModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.offPostMonitor:
        model.offPostMonitorModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.offPostMonitorModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.offPostMonitorModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.carRetrograde:
        model.carRetrogradeModel.value?.lightLed.value = enable ? 1 : 0;
        var config = model.carRetrogradeModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            model.carRetrogradeModel.value?.lightLed.value = enable ? 0 : 1;
          }
        }
        break;
      case AiType.packageDetect:
        if (state!.currentPackageIndex.value == 0) {
          model.packageDetectModel.value?.appearLightLed.value = enable ? 1 : 0;
        } else if (state!.currentPackageIndex.value == 1) {
          model.packageDetectModel.value?.disappearLightLed.value =
              enable ? 1 : 0;
        } else if (state!.currentPackageIndex.value == 2) {
          model.packageDetectModel.value?.stayLightLed.value = enable ? 1 : 0;
        }
        var config = model.packageDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            if (state!.currentPackageIndex.value == 0) {
              model.packageDetectModel.value?.appearLightLed.value =
                  enable ? 0 : 1;
            } else if (state!.currentPackageIndex.value == 1) {
              model.packageDetectModel.value?.disappearLightLed.value =
                  enable ? 0 : 1;
            } else if (state!.currentPackageIndex.value == 2) {
              model.packageDetectModel.value?.stayLightLed.value =
                  enable ? 0 : 1;
            }
          }
        }
        break;
      case AiType.fireSmokeDetect:
        if (state!.currentFireSmokeIndex.value == 0) {
          model.fireSmokeDetectModel.value?.fireLightLed.value = enable ? 1 : 0;
        } else if (state!.currentFireSmokeIndex.value == 1) {
          model.fireSmokeDetectModel.value?.smokeLightLed.value =
              enable ? 1 : 0;
        }
        var config = model.fireSmokeDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await aiDetectionLogic.setAiDetectData(type, config);
          if (!bl) {
            if (state!.currentFireSmokeIndex.value == 0) {
              model.fireSmokeDetectModel.value?.fireLightLed.value =
                  enable ? 0 : 1;
            } else if (state!.currentFireSmokeIndex.value == 1) {
              model.fireSmokeDetectModel.value?.smokeLightLed.value =
                  enable ? 0 : 1;
            }
          }
        }
        break;
      case AiType.none:
        // TODO: Handle this case.
        break;
    }
    state!.flashFlag.value++;
  }
}
