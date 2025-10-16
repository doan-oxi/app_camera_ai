import '../../utils/device_manager.dart';
import '../../utils/manager.dart';
import '../../utils/super_put_controller.dart';
import '../Settings_logic.dart';
import 'detect_area_draw_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:math';
import 'package:get/get.dart';

class DetectAreaDrawLogic extends SuperPutController<DetectAreaDrawState> {
  DetectAreaDrawLogic() {
    value = DetectAreaDrawState();
  }

  @override
  void onInit() {
    int sensorIndex = 0;
    getAreaData(sensorIndex, 0);
    if (Manager().getDeviceManager()!.deviceModel!.supportMutilSensorStream >=
        1) {
      sensorIndex = 1;
      if (Manager()
              .getDeviceManager()!
              .deviceModel!
              .supportMutilSensorStream
              .value ==
          4) {
        sensorIndex = 3;
      }
      getAreaData(sensorIndex, 1);
    }
    if (Manager()
            .getDeviceManager()!
            .deviceModel!
            .supportMutilSensorStream
            .value >=
        3) {
      int sensorIndex = 2;
      if (Manager().getDeviceManager()!.deviceModel!.splitScreen.value == 1) {
        sensorIndex = 1;
      }
      getAreaData(sensorIndex, 2);
    }
    if (Manager()
            .getDeviceManager()!
            .deviceModel!
            .supportMutilSensorStream
            .value >=
        4) {
      sensorIndex = 1;
      getAreaData(sensorIndex, 3);
    }

    super.onInit();
  }

  void save(List data, {index = 0}) {
    List records = getAreaRecords(data);
    SettingsLogic settingsLogic = Get.find<SettingsLogic>();
    if (settingsLogic.state!.motionPushEnable.value == 1) {
      //移动侦测
      saveArea(0, records, index: index);
    } else if (settingsLogic.state!.motionPushEnable.value == 5) {
      //人形侦测
      saveArea(2, records, index: index);
    }
  }

  ///计算每行的值
  List getAreaRecords(data) {
    List records = [];
    for (int i = 0; i < data.length; i++) {
      int total = 0;
      int length = data[i].length;
      List list = data[i];
      list = list.reversed.toList();
      for (int j = 0; j < length; j++) {
        total = total + (list[j] * pow(2, j)) as int;
      }
      records.add(total);
    }
    return records;
  }

  ///cmd: 0 移动侦测，2人形侦测
  saveArea(int cmd, List records, {index = 0}) async {
    bool bl = await Manager().getDeviceManager()!.mDevice?.setAlarmCustomeZone(
            records: records, command: cmd, sensor: index) ??
        false;
    if (bl) {
      EasyLoading.showToast("保存成功！");
    }
  }

  ///cmd: 1移动 3人形
  getAreaData(int index, int dataIndex) async {
    SettingsLogic settingsLogic = Get.find<SettingsLogic>();
    bool bl = false;
    int cmd = 1;
    if (settingsLogic.state!.motionPushEnable.value == 1) {
      //移动侦测
      bl = await Manager()
              .getDeviceManager()!
              .mDevice
              ?.getAlarmCustomeZone(1, sensor: index) ??
          false;
    } else if (settingsLogic.state!.motionPushEnable.value == 5) {
      cmd = 3;
      //人形侦测
      bl = await Manager()
              .getDeviceManager()!
              .mDevice
              ?.getAlarmCustomeZone(3, sensor: index) ??
          false;
    }
    if (bl) {
      List<int> data = dealWithData(cmd);
      getZoneData(data, dataIndex);
    }
    return [];
  }

  List<int> dealWithData(int cmd) {
    Map customZone =
        Manager().getDeviceManager()!.mDevice?.customeZoneData ?? {};
    print("--------getAreaData------success------");

    String reignString = "md_";
    switch (cmd) {
      case 1: //CustomAreaType_MoveDetect 获取移动侦测区域
        reignString = "md_";
        break;
      case 3: //CustomAreaType_HumanDetect 获取人形侦测区域
        reignString = "pd_";
        break;
      // case 5: //CustomAreaType_OffDuty 获取离岗侦测区域
      //   reignString = "depart_";
      //   break;
      // case 7: //CustomAreaType_FaceDetect  获取人脸侦测区域
      //   reignString = "face_detect_";
      //   break;
      // case 9: //CustomAreaType_FaceDiscernment  获取人脸识别区域
      //   reignString = "face_recognition_";
      //   break;
      // default:
      //   break;
    }
    List<int> temp = [];
    for (int i = 0; i < 18; i++) {
      String reign = "${reignString}reign$i";
      if (customZone[reign] != null) {
        temp.add(int.tryParse(customZone[reign]) ?? 0);
      } else {
        temp.add(0);
      }
    }
    return temp;
  }

  ///数据转换
  List<List<int>> getZoneData(List<int> listData, int index) {
    print("listData>>>$listData >>>length ${listData.length}");
    List<List<int>> gridData = List.generate(18, (index) => List.filled(22, 1));
    if (listData.length > 0) {
      for (int i = 0; i < listData.length; i++) {
        //18行
        List<String> res = listData[i].toRadixString(2).split("").toList();
        int length = res.length;
        //前面补0
        if (length < 22) {
          for (int i = 0; i < 22 - length; i++) {
            res.insert(0, "0");
          }
        }
        //print(res);
        for (int j = 0; j < res.length; j++) {
          if (int.tryParse(res[j]) == 0) {
            gridData[i][j] = 0;
          }
        }
      }
    }
    if (index == 0) {
      state?.gridState(gridData);
    } else if (index == 1) {
      state?.gridState1(gridData);
    } else if (index == 2) {
      state?.gridState2(gridData);
    } else if (index == 3) {
      state?.gridState3(gridData);
    }

    return gridData;
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
