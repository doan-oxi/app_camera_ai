import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';

mixin AIPackageStayTimeLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIPackageStayTimeLogic>(this);
    super.initPut();
  }

  String getStayTimeName(int index) {
    String name = "10分钟";
    switch (index) {
      case 0:
        name = "10分钟";
        break;
      case 1:
        name = "30分钟";
        break;
      case 2:
        name = "1小时";
        break;
      case 3:
        name = "6小时";
        break;
      case 4:
        name = "12小时";
        break;
      case 5:
        name = "24小时";
        break;
      case 6:
        name = "48小时";
        break;
      case 7:
        name = "72小时";
        break;
    }
    return name;
  }

  void setTime(int index) {
    int seconds = 10 * 60;
    switch (index) {
      case 0:
        seconds = 10 * 60;
        break;
      case 1:
        seconds = 30 * 60;
        break;
      case 2:
        seconds = 60 * 60;
        break;
      case 3:
        seconds = 6 * 60 * 60;
        break;
      case 4:
        seconds = 12 * 60 * 60;
        break;
      case 5:
        seconds = 24 * 60 * 60;
        break;
      case 6:
        seconds = 48 * 60 * 60;
        break;
      case 7:
        seconds = 72 * 60 * 60;
        break;
    }
    setPackageStayTime(seconds);
  }

  void getTimeIndex() {
    int seconds = Manager()
            .getDeviceManager()
            ?.deviceModel
            ?.packageDetectModel
            .value
            ?.stayTime
            .value ??
        600;
    int index = 0;
    switch (seconds) {
      case 10 * 60:
        index = 0;
        break;
      case 30 * 60:
        index = 1;
        break;
      case 60 * 60:
        index = 2;
        break;
      case 6 * 60 * 60:
        index = 3;
        break;
      case 12 * 60 * 60:
        index = 4;
        break;
      case 24 * 60 * 60:
        index = 5;
        break;
      case 48 * 60 * 60:
        index = 6;
        break;
      case 72 * 60 * 60:
        index = 7;
        break;
    }
    state!.stayTimeIndex.value = index;
  }

  void setPackageStayTime(int seconds) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (model == null) return;
    int? tempTime = model.packageDetectModel.value?.stayTime.value;
    model.packageDetectModel.value?.stayTime.value = seconds;
    var config = model.packageDetectModel.value?.toJsonString();
    if (config != null) {
      bool bl =
          await aiDetectionLogic.setAiDetectData(AiType.packageDetect, config);
      if (!bl) {
        model.packageDetectModel.value?.stayTime.value = tempTime ?? 10 * 60;
      } else {
        Get.back();
      }
    }
  }
}
