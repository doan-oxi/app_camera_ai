import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/package_stay_time/ai_package_stay_time_logic.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/person_count/ai_person_count_logic.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/sensitivity/ai_sensitivity_logic.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/stay_time/ai_stay_time_logic.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/target_frame/ai_target_frame_logic.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/target_type/ai_target_type_logic.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../../utils/manager.dart';
import '../../utils/super_put_controller.dart';
import 'ai_detect_setting_conf.dart';
import 'ai_detect_setting_state.dart';
import 'alarm_plan/ai_alarm_plan_logic.dart';
import 'alarm_sound/ai_alarm_sound_logic.dart';
import 'fire_smoke/fire_smoke_logic.dart';
import 'fire_smoke_scene/ai_fire_smoke_scene_logic.dart';
import 'flash_light/ai_flash_light_logic.dart';
import 'leave_time/ai_leave_time_logic.dart';
import 'package/package_logic.dart';

class AIDetectSettingLogic extends SuperPutController<AIDetectSettingState>
    with
        AIAlarmSoundLogic,
        AITargetFrameLogic,
        AITargetTypeLogic,
        AIFlashLightLogic,
        AISensitivityLogic,
        AILeaveTimeLogic,
        AIFireSmokeLogic,
        AIPackageLogic,
        AIPersonCountLogic,
        AIFireSmokeSceneLogic,
        AIAlarmPlanLogic,
        AIStayTimeLogic,
        AIPackageStayTimeLogic {
  TextEditingController textController = TextEditingController();
  String name = "";

  AIDetectSettingLogic() {
    value = AIDetectSettingState();
    initPut();
  }

  @override
  void onInit() {
    var args = Get.arguments;
    if (args is AIDetectSettingArgs) {
      state!.aiType.value = args.aiType;
    }
    setName();
    initIsOpen();
    getVoiceInfo();
    initStayTime();
    initLeaveTime();
    initTargetState();
    initCountState();
    initIsShow();
    initFireSmokeScene();
    getAiMotionAlarmPlan();
    super.onInit();
  }

  ///切换包裹类型/火灾烟雾类型后，重新获取声音、闪光灯等功能的状态
  void reGetInfo() {
    getVoiceInfo();
    state!.flashFlag.value++;
    state!.sensitivityFlag.value++;
    if (state!.aiType.value == AiType.packageDetect &&
        state!.currentPackageIndex.value == 2) {
      getTimeIndex();
    }
  }

  initIsShow() {
    if (state!.aiType.value == AiType.packageDetect) {
      if (Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.packageDetectModel
              .value
              ?.appearEnable
              .value ==
          1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    } else if (state!.aiType.value == AiType.fireSmokeDetect) {
      if (Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.fireSmokeDetectModel
              .value
              ?.fireEnable
              .value ==
          1) {
        state!.isShow.value = true;
      } else {
        state!.isShow.value = false;
      }
    } else {
      state!.isShow.value = true;
    }
  }

  void setName() {
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        name = "区域入侵监测";
        break;
      case AiType.personStay:
        name = "人员逗留监测";
        break;
      case AiType.illegalParking:
        name = "车辆违停监测";
        break;
      case AiType.crossBorder:
        name = "越界监测";
        break;
      case AiType.offPostMonitor:
        name = "离岗监测";
        break;
      case AiType.carRetrograde:
        name = "车辆逆行监测";
        break;
      case AiType.packageDetect:
        name = "包裹识别";
        break;
      case AiType.fireSmokeDetect:
        name = "火灾监测";
        break;
    }
  }

  @override
  void onClose() {
    print("-------onClose-----------");

    super.onClose();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    print("--------onDelete-------");

    return super.onDelete;
  }

  void initIsOpen() {
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return;
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        state!.isOpen.value =
            deviceModel.areaIntrusionModel.value?.enable.value == 1;
        break;
      case AiType.personStay:
        state!.isOpen.value =
            deviceModel.personStayModel.value?.enable.value == 1;
        break;
      case AiType.illegalParking:
        state!.isOpen.value =
            deviceModel.illegalParkingModel.value?.enable.value == 1;
        break;
      case AiType.crossBorder:
        state!.isOpen.value =
            deviceModel.crossBorderModel.value?.enable.value == 1;
        break;
      case AiType.offPostMonitor:
        state!.isOpen.value =
            deviceModel.offPostMonitorModel.value?.enable.value == 1;
        break;
      case AiType.carRetrograde:
        state!.isOpen.value =
            deviceModel.carRetrogradeModel.value?.enable.value == 1;
        break;
      case AiType.packageDetect:
        state!.isOpen.value =
            (deviceModel.packageDetectModel.value?.appearEnable.value == 1) ||
                (deviceModel.packageDetectModel.value?.disappearEnable.value ==
                    1) ||
                (deviceModel.packageDetectModel.value?.stayEnable.value == 1);
        break;
      case AiType.fireSmokeDetect:
        state!.isOpen.value =
            (deviceModel.fireSmokeDetectModel.value?.fireEnable.value == 1) ||
                (deviceModel.fireSmokeDetectModel.value?.smokeEnable.value ==
                    1);
        break;
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
