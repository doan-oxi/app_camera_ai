import 'package:vsdk_example/utils/device_manager.dart';

import '../../../model/device_model.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

mixin AITargetTypeLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AITargetTypeLogic>(this);
    super.initPut();
  }

  void setTargetType() async {
    if (!state!.target0Selected.value &&
        !state!.target1Selected.value &&
        !state!.target2Selected.value) {
      EasyLoading.showToast("请至少选择一种目标类型");
      return;
    }
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) {
      return;
    }
    var temp = 1;
    if (state!.aiType.value == AiType.areaIntrusion) {
      temp = deviceModel.areaIntrusionModel.value?.object.value ?? 1;
    } else if (state!.aiType.value == AiType.crossBorder) {
      temp = deviceModel.crossBorderModel.value?.object.value ?? 1;
    }

    int targetValue = getTargetValue();

    var config;
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    if (state!.aiType.value == AiType.areaIntrusion) {
      deviceModel.areaIntrusionModel.value?.object.value = targetValue;
      config = deviceModel.areaIntrusionModel.value?.toJsonString();
      if (config != null) {
        bool bl = await aiDetectionLogic.setAiDetectData(
            AiType.areaIntrusion, config);
        if (!bl) {
          deviceModel.areaIntrusionModel.value?.object.value = temp;
        } else {
          state!.targetType.value = targetValue;
          EasyLoading.showToast("设置成功！");
          Get.back();
        }
      }
    } else if (state!.aiType.value == AiType.crossBorder) {
      deviceModel.crossBorderModel.value?.object.value = targetValue;
      config = deviceModel.crossBorderModel.value?.toJsonString();
      if (config != null) {
        bool bl =
            await aiDetectionLogic.setAiDetectData(AiType.crossBorder, config);
        if (!bl) {
          deviceModel.crossBorderModel.value?.object.value = temp;
        } else {
          state!.targetType.value = targetValue;
          EasyLoading.showToast("设置成功！");
          Get.back();
        }
      }
    }
  }

  String getSelectedName(int value) {
    switch (value) {
      case 1:
        return "人 >>";
      case 2:
        return "车 >>";
      case 3:
        return "人/车 >>";
      case 4:
        return "宠物 >>";
      case 5:
        return "人/宠物 >>";
      case 6:
        return "车/宠物 >>";
      case 7:
        return "人/车/宠物 >>";
    }
    return "人 >>";
  }

  int getTargetValue() {
    var targetValue = 1;

    ///人
    if (state!.target0Selected.value &&
        !state!.target1Selected.value &&
        !state!.target2Selected.value) {
      targetValue = 1;
    }

    ///车
    if (!state!.target0Selected.value &&
        state!.target1Selected.value &&
        !state!.target2Selected.value) {
      targetValue = 2;
    }

    ///宠物
    if (!state!.target0Selected.value &&
        !state!.target1Selected.value &&
        state!.target2Selected.value) {
      targetValue = 4;
    }

    ///人、车
    if (state!.target0Selected.value &&
        state!.target1Selected.value &&
        !state!.target2Selected.value) {
      targetValue = 3;
    }

    ///人、宠物
    if (state!.target0Selected.value &&
        !state!.target1Selected.value &&
        state!.target2Selected.value) {
      targetValue = 5;
    }

    ///车、宠物
    if (!state!.target0Selected.value &&
        state!.target1Selected.value &&
        state!.target2Selected.value) {
      targetValue = 6;
    }

    ///人、车、宠物
    if (state!.target0Selected.value &&
        state!.target1Selected.value &&
        state!.target2Selected.value) {
      targetValue = 7;
    }
    return targetValue;
  }

  void initTargetState() {
    int targetV = 1;
    if (state!.aiType.value == AiType.areaIntrusion) {
      targetV = Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.areaIntrusionModel
              .value
              ?.object
              .value ??
          1;
    } else if (state!.aiType.value == AiType.crossBorder) {
      targetV = Manager()
              .getDeviceManager()
              ?.deviceModel
              ?.crossBorderModel
              .value
              ?.object
              .value ??
          1;
    }
    state!.targetType.value = targetV;
    getTargetState(targetV);
  }

  getTargetState(int value) {
    switch (value) {
      case 1: //人
        state!.target0Selected.value = true;
        state!.target1Selected.value = false;
        state!.target2Selected.value = false;
        break;
      case 2: //车
        state!.target0Selected.value = false;
        state!.target1Selected.value = true;
        state!.target2Selected.value = false;
        break;
      case 3: //人和车
        state!.target0Selected.value = true;
        state!.target1Selected.value = true;
        state!.target2Selected.value = false;
        break;
      case 4: //宠物
        state!.target0Selected.value = false;
        state!.target1Selected.value = false;
        state!.target2Selected.value = true;
        break;
      case 5: //人和宠物
        state!.target0Selected.value = true;
        state!.target1Selected.value = false;
        state!.target2Selected.value = true;
        break;
      case 6: //车和宠物
        state!.target0Selected.value = false;
        state!.target1Selected.value = true;
        state!.target2Selected.value = true;
        break;
      case 7: //人、车、宠物
        state!.target0Selected.value = true;
        state!.target1Selected.value = true;
        state!.target2Selected.value = true;
        break;
    }
  }
}
