import 'package:flutter/cupertino.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/area_draw/area_draw_conf.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import 'area_draw_state.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AiAreaDrawLogic extends SuperPutController<AiAreaDrawState> {
  AiAreaDrawLogic() {
    value = AiAreaDrawState();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInit() {
    var args = Get.arguments;
    if (args is AIAreaDrawArgs) {
      state!.aiType.value = args.aiType;
    }
    initArea();
    super.onInit();
  }

  ///侦测区域绘制初始化
  initArea() {
    if (state!.aiType.value == AiType.crossBorder ||
        state!.aiType.value == AiType.carRetrograde ||
        state!.aiType.value == AiType.fireSmokeDetect) {
      ///越界和车辆逆行不适用该逻辑，火灾烟雾监测没有区域绘制
      return;
    }
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    Map<String, Map<String, Map<String, double>>> fixMap = getFixMap();
    if (deviceModel == null) return;
    if (state!.aiType.value == AiType.areaIntrusion) {
      print(
          "---------${deviceModel.areaIntrusionModel.value?.areaMap}-------------");
      var temMap = deviceModel.areaIntrusionModel.value?.areaMap;
      compareValue(temMap, fixMap);
    }
    if (state!.aiType.value == AiType.personStay) {
      print(
          "---------${deviceModel.personStayModel.value?.areaMap}-------------");
      var temMap = deviceModel.personStayModel.value?.areaMap;
      compareValue(temMap, fixMap);
    }
    if (state!.aiType.value == AiType.illegalParking) {
      print(
          "---------${deviceModel.illegalParkingModel.value?.areaMap}-------------");
      var temMap = deviceModel.illegalParkingModel.value?.areaMap;
      compareValue(temMap, fixMap);
    }
    if (state!.aiType.value == AiType.offPostMonitor) {
      print(
          "---------${deviceModel.offPostMonitorModel.value?.areaMap}-------------");
      var temMap = deviceModel.offPostMonitorModel.value?.areaMap;
      compareValue(temMap, fixMap);
    }
    if (state!.aiType.value == AiType.packageDetect) {
      print(
          "---------${deviceModel.packageDetectModel.value?.areaMap}-------------");
      var temMap = deviceModel.packageDetectModel.value?.areaMap;
      compareValue(temMap, fixMap);
    }
  }

  void compareValue(Map<dynamic, dynamic>? temMap,
      Map<String, Map<String, Map<String, double>>> fixMap) {
    if (temMap != null && temMap.isNotEmpty) {
      var newMap = temMap.map((key, value) {
        return MapEntry(key, value.map((key, value) {
          return MapEntry(key, {
            "x": value["x"].ceil().toDouble(),
            "y": value["y"].ceil().toDouble(),
          });
        }));
      });
      print("---------$newMap-------------");
      if (fixMap.toString() == newMap.toString()) {
        state!.index.value = 1;
      } else {
        state!.index.value = 0;
      }
    }
  }

  ///侦测区域绘制
  void setAreaDraw(BuildContext context, int index) async {
    if (state!.aiType.value == AiType.crossBorder ||
        state!.aiType.value == AiType.carRetrograde ||
        state!.aiType.value == AiType.fireSmokeDetect) {
      ///越界和车辆逆行不适用该逻辑，火灾烟雾监测没有区域绘制
      return;
    }
    print("----------index-$index----------");
    var num = 0;
    var padding = 0.0;
    var width = MediaQuery.of(context).size.width;
    var height = width * 9 / 16;
    Map<String, Map<String, Map<String, double>>> defaultMap =
        getDefaultMap(num, padding, height, width);
    Map<String, Map<String, Map<String, double>>> fixMap = getFixMap();

    var areaMap;
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return;
    if (index == 0) {
      areaMap = defaultMap;
    } else {
      areaMap = fixMap;
    }
    var config;
    if (state!.aiType.value == AiType.areaIntrusion) {
      deviceModel.areaIntrusionModel.value?.areaMap.clear();
      deviceModel.areaIntrusionModel.value?.areaMap.addAll(areaMap);
      config = deviceModel.areaIntrusionModel.value?.toJsonString();
    }
    if (state!.aiType.value == AiType.personStay) {
      deviceModel.personStayModel.value?.areaMap.clear();
      deviceModel.personStayModel.value?.areaMap.addAll(areaMap);
      config = deviceModel.personStayModel.value?.toJsonString();
    }
    if (state!.aiType.value == AiType.illegalParking) {
      deviceModel.illegalParkingModel.value?.areaMap.clear();
      deviceModel.illegalParkingModel.value?.areaMap.addAll(areaMap);
      config = deviceModel.illegalParkingModel.value?.toJsonString();
    }
    if (state!.aiType.value == AiType.offPostMonitor) {
      deviceModel.offPostMonitorModel.value?.areaMap.clear();
      deviceModel.offPostMonitorModel.value?.areaMap.addAll(areaMap);
      config = deviceModel.offPostMonitorModel.value?.toJsonString();
    }
    if (state!.aiType.value == AiType.packageDetect) {
      deviceModel.packageDetectModel.value?.areaMap.clear();
      deviceModel.packageDetectModel.value?.areaMap.addAll(areaMap);
      config = deviceModel.packageDetectModel.value?.toJsonString();
    }
    print("---------areaMap--$areaMap----------");
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    bool bl =
        await aiDetectionLogic.setAiDetectData(state!.aiType.value!, config!);
    if (bl) {
      state!.index.value = index;
    }
  }

  Map<String, Map<String, Map<String, double>>> getDefaultMap(
      int num, double padding, double height, double width) {
    var defaultMap = {
      "$num": {
        "0": {"x": 0.0 + padding, "y": 0.0 + padding},
        "1": {"x": 0.0 + padding, "y": height - padding},
        "2": {"x": width - padding, "y": height - padding},
        "3": {"x": width - padding, "y": 0.0 + padding}
      },
    };
    return defaultMap;
  }

  Map<String, Map<String, Map<String, double>>> getFixMap() {
    var fixMap = {
      "0": {
        "0": {"x": state!.points1[0].dx, "y": state!.points1[0].dy},
        "1": {"x": state!.points1[1].dx, "y": state!.points1[1].dy},
        "2": {"x": state!.points1[2].dx, "y": state!.points1[2].dy},
        "3": {"x": state!.points1[3].dx, "y": state!.points1[3].dy}
      },
      "1": {
        "0": {"x": state!.points2[0].dx, "y": state!.points2[0].dy},
        "1": {"x": state!.points2[1].dx, "y": state!.points2[1].dy},
        "2": {"x": state!.points2[2].dx, "y": state!.points2[2].dy}
      },
    };
    return fixMap;
  }

  void setCrossBorder() async {
    ///demoMap的point对应borderLineWidget的两个点坐标，实际的值请根据实际情况修改
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return;
    var demoMap = {
      "0": {
        'point': {
          "0": {"x": 200.0, "y": 50.0},
          "1": {"x": 200.0, "y": 200.0}
        },
        'dir': 1, //方向，左->右：1，右->左：0
      },
    };
    deviceModel.crossBorderModel.value?.areaMap.clear();
    deviceModel.crossBorderModel.value?.areaMap.addAll(demoMap);
    var config = deviceModel.crossBorderModel.value?.toJsonString();
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    bool bl =
        await aiDetectionLogic.setAiDetectData(AiType.crossBorder, config!);
    if (bl) {
      EasyLoading.showToast("设置成功");
    }
  }

  ///设置车辆逆行区域
  void setCarArea() async {
    ///demoMap的point对应borderLineWidget的两个点坐标，实际的值请根据实际情况修改
    DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
    if (deviceModel == null) return;

    ///对应carAreaWidget 的四个点坐标
    var demoMap = {
      "0": {
        'point': {
          "0": {"x": 20.0, "y": 20.0},
          "1": {"x": 20.0, "y": 160.0},
          "2": {"x": 300.0, "y": 160.0},
          "3": {"x": 300.0, "y": 20.0},
        },
        'selectedLine': 1, //方向，0:向左，1:向下，2:向右，3:向上
      },
    };
    deviceModel.carRetrogradeModel.value?.areaMap.clear();
    deviceModel.carRetrogradeModel.value?.areaMap.addAll(demoMap);
    var config = deviceModel.carRetrogradeModel.value?.toJsonString();
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    bool bl =
        await aiDetectionLogic.setAiDetectData(AiType.carRetrograde, config!);
    if (bl) {
      EasyLoading.showToast("设置成功");
    }
  }
}
