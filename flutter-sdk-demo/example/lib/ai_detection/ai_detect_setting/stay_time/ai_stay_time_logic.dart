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

mixin AIStayTimeLogic on SuperPutController<AIDetectSettingState> {
  TextEditingController timeTextController = TextEditingController();

  @override
  void initPut() {
    lazyPut<AIStayTimeLogic>(this);
    super.initPut();
  }

  void initStayTime() {
    if (state!.aiType.value == AiType.personStay) {
      state!.stayTime.value = Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.personStayModel
              .value
              ?.staytime
              .value ??
          30;
    } else if (state!.aiType.value == AiType.illegalParking) {
      state!.stayTime.value = Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.illegalParkingModel
              .value
              ?.staytime
              .value ??
          30;
    }
  }

  void setStayTime() async {
    String seconds = timeTextController.text.trim();
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
    if (state!.aiType.value == AiType.personStay) {
      int? tempTime = model.personStayModel.value?.staytime.value;
      model.personStayModel.value?.staytime.value = second;
      var config = model.personStayModel.value?.toJsonString();
      if (config != null) {
        bool bl =
            await aiDetectionLogic.setAiDetectData(AiType.personStay, config);
        if (!bl) {
          model.personStayModel.value?.staytime.value = tempTime ?? 30;
        } else {
          state!.stayTime.value = second;
          EasyLoading.showToast("设置成功！");
          Get.back();
        }
      }
    } else if (state!.aiType.value == AiType.illegalParking) {
      int? tempTime = model.illegalParkingModel.value?.staytime.value;
      model.illegalParkingModel.value?.staytime.value = second;
      var config = model.illegalParkingModel.value?.toJsonString();
      if (config != null) {
        bool bl = await aiDetectionLogic.setAiDetectData(
            AiType.illegalParking, config);
        if (!bl) {
          model.illegalParkingModel.value?.staytime.value = tempTime ?? 30;
        } else {
          state!.stayTime.value = second;
          EasyLoading.showToast("设置成功！");
          Get.back();
        }
      }
    }
  }
}
