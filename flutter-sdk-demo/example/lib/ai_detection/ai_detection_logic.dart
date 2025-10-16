import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk/camera_device/camera_device.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../utils/app_web_api.dart';
import '../utils/manager.dart';
import '../utils/super_put_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'ai_detect_model.dart';
import 'ai_detect_setting/ai_detect_setting_logic.dart';
import 'ai_detection_state.dart';

class AIDetectionLogic extends SuperPutController<AIDetectionState> {
  TextEditingController textController = TextEditingController();
  Timer? thisTimer;

  AIDetectionLogic() {
    value = AIDetectionState();
  }

  @override
  void onInit() {
    String did = Manager().getCurrentUid();
    getAreaIntrusionData(did);
    getCrossBorderData(did);
    getOffPostMonitorData(did);
    getPackageDetectData(did);
    getIllegalParkingData(did);
    getPersonStayData(did);
    getCarRetrogradeData(did);
    getFireSmokeDetectData(did);
    requestAiData();
    super.onInit();
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

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  ///区域入侵
  getAreaIntrusionData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI004');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.areaIntrusionFunctionStatus.value = 1;
          } else if (current > end) {
            model?.areaIntrusionFunctionStatus.value = 3;
          }
        } else {
          model?.areaIntrusionFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///越界监测
  getCrossBorderData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI006');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.crossBorderModelFunctionStatus.value = 1;
          } else if (current > end) {
            model?.crossBorderModelFunctionStatus.value = 3;
          }
        } else {
          model?.crossBorderModelFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///离岗监测
  getOffPostMonitorData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI001');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.offPostMonitorFunctionStatus.value = 1;
          } else if (current > end) {
            model?.offPostMonitorFunctionStatus.value = 3;
          }
        } else {
          model?.offPostMonitorFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///包裹识别
  getPackageDetectData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI002');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.packageDetectModelFunctionStatus.value = 1;
          } else if (current > end) {
            model?.packageDetectModelFunctionStatus.value = 3;
          }
        } else {
          model?.packageDetectModelFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///车辆违停
  getIllegalParkingData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI003');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.illegalParkingFunctionStatus.value = 1;
          } else if (current > end) {
            model?.illegalParkingFunctionStatus.value = 3;
          }
        } else {
          model?.illegalParkingFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///人员逗留
  getPersonStayData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI005');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.personStayFunctionStatus.value = 1;
          } else if (current > end) {
            model?.personStayFunctionStatus.value = 3;
          }
        } else {
          model?.personStayFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///车辆逆行
  getCarRetrogradeData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI007');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.carRetrogradeModelFunctionStatus.value = 1;
          } else if (current > end) {
            model?.carRetrogradeModelFunctionStatus.value = 3;
          }
        } else {
          model?.carRetrogradeModelFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///烟雾监测
  getFireSmokeDetectData(String did) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    var response = await AppWebApi().requestAiTrialShow(did, 'AI008');
    if (response.statusCode == 200) {
      var info = response.data;
      if (info is Map) {
        if (info.keys.contains('start') && info.keys.contains('end')) {
          var start = info['start'];
          var end = info['end'];
          var state = info['state'];
          var current = DateTime.now().millisecondsSinceEpoch / 1000;
          if (current > start && current <= end) {
            model?.fireSmokeDetectModelFunctionStatus.value = 1;
          } else if (current > end) {
            model?.fireSmokeDetectModelFunctionStatus.value = 3;
          }
        } else {
          model?.fireSmokeDetectModelFunctionStatus.value = 0;
        }
        state!.aiGet.value++;
      }
    }
  }

  ///获取AI智能服务数据
  Future<Map<String, dynamic>?> getAiDetectData(AiType type) async {
    CameraDevice? basisDevice = Manager().getDeviceManager()?.mDevice;
    if (basisDevice is CameraDevice) {
      int aiType;
      switch (type) {
        case AiType.areaIntrusion:
          aiType = 0;
          break;
        case AiType.personStay:
          aiType = 1;
          break;
        case AiType.illegalParking:
          aiType = 2;
          break;
        case AiType.crossBorder:
          aiType = 3;
          break;
        case AiType.offPostMonitor:
          aiType = 4;
          break;
        case AiType.carRetrograde:
          aiType = 5;
          break;
        case AiType.packageDetect:
          aiType = 6;
          break;
        case AiType.fireSmokeDetect:
          aiType = 7;
          break;
        default:
          aiType = 0;
          break;
      }

      bool result =
          await basisDevice.aiDetect?.getAiDetectData(aiType) ?? false;
      if (result == true) {
        return basisDevice.aiDetect?.aiConfigMap;
      }
    }
    return null;
  }

  ///设置AI智能服务数据
  Future<bool> setAiDetectData(AiType type, String config) async {
    CameraDevice? basisDevice = Manager().getDeviceManager()?.mDevice;
    if (basisDevice is CameraDevice) {
      int aiType;
      switch (type) {
        case AiType.areaIntrusion:
          aiType = 0;
          break;
        case AiType.personStay:
          aiType = 1;
          break;
        case AiType.illegalParking:
          aiType = 2;
          break;
        case AiType.crossBorder:
          aiType = 3;
          break;
        case AiType.offPostMonitor:
          aiType = 4;
          break;
        case AiType.carRetrograde:
          aiType = 5;
          break;
        case AiType.packageDetect:
          aiType = 6;
          break;
        case AiType.fireSmokeDetect:
          aiType = 7;
          break;
        default:
          aiType = 0;
          break;
      }

      bool result =
          await basisDevice.aiDetect?.setAiDetectData(aiType, config) ?? false;
      return result;
    }
    return false;
  }

  void requestAiData() async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    if (model.isSupportAreaIntrusion.value) {
      var aiDetectMap = await getAiDetectData(AiType.areaIntrusion);
      if (aiDetectMap is Map) {
        model.areaIntrusionModel.value =
            AreaIntrusionModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportCarRetrograde.value) {
      var aiDetectMap = await getAiDetectData(AiType.carRetrograde);
      if (aiDetectMap is Map) {
        model.carRetrogradeModel.value =
            CarRetrogradeModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportCrossBorder.value) {
      var aiDetectMap = await getAiDetectData(AiType.crossBorder);
      if (aiDetectMap is Map) {
        model.crossBorderModel.value =
            CrossBorderModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportFireSmokeDetect.value) {
      var aiDetectMap = await getAiDetectData(AiType.fireSmokeDetect);
      if (aiDetectMap is Map) {
        model.fireSmokeDetectModel.value =
            FireSmokeDetectModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportIllegalParking.value) {
      var aiDetectMap = await getAiDetectData(AiType.illegalParking);
      if (aiDetectMap is Map) {
        model.illegalParkingModel.value =
            IllegalParkingModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportOffPostMonitor.value) {
      var aiDetectMap = await getAiDetectData(AiType.offPostMonitor);
      if (aiDetectMap is Map) {
        model.offPostMonitorModel.value =
            OffPostMonitorModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportPackageDetect.value) {
      var aiDetectMap = await getAiDetectData(AiType.packageDetect);
      if (aiDetectMap is Map) {
        model.packageDetectModel.value =
            PackageDetectModel.fromJson(aiDetectMap ?? {});
      }
    }

    if (model.isSupportPersonStay.value) {
      var aiDetectMap = await getAiDetectData(AiType.personStay);
      if (aiDetectMap is Map) {
        model.personStayModel.value =
            PersonStayModel.fromJson(aiDetectMap ?? {});
      }
    }
  }

  Future<bool> controlDetectSwitch(bool enable, AiType type) async {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return false;
    switch (type) {
      case AiType.areaIntrusion:
        model.areaIntrusionModel.value?.enable.value = enable ? 1 : 0;
        var config = model.areaIntrusionModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.areaIntrusionModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.personStay:
        model.personStayModel.value?.enable.value = enable ? 1 : 0;
        var config = model.personStayModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.personStayModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.illegalParking:
        model.illegalParkingModel.value?.enable.value = enable ? 1 : 0;
        var config = model.illegalParkingModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.illegalParkingModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.crossBorder:
        model.crossBorderModel.value?.enable.value = enable ? 1 : 0;
        var config = model.crossBorderModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.crossBorderModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.offPostMonitor:
        model.offPostMonitorModel.value?.enable.value = enable ? 1 : 0;
        var config = model.offPostMonitorModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.offPostMonitorModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.carRetrograde:
        model.carRetrogradeModel.value?.enable.value = enable ? 1 : 0;
        var config = model.carRetrogradeModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.carRetrogradeModel.value?.enable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.packageDetect:
        model.packageDetectModel.value?.appearEnable.value = enable ? 1 : 0;
        model.packageDetectModel.value?.disappearEnable.value = enable ? 1 : 0;
        model.packageDetectModel.value?.stayEnable.value = enable ? 1 : 0;
        var config = model.packageDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.packageDetectModel.value?.appearEnable.value = enable ? 0 : 1;
            model.packageDetectModel.value?.disappearEnable.value =
                enable ? 0 : 1;
            model.packageDetectModel.value?.stayEnable.value = enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
      case AiType.fireSmokeDetect:
        model.fireSmokeDetectModel.value?.fireEnable.value = enable ? 1 : 0;
        model.fireSmokeDetectModel.value?.smokeEnable.value = enable ? 1 : 0;
        var config = model.fireSmokeDetectModel.value?.toJsonString();
        if (config != null) {
          bool bl = await setAiDetectData(type, config);
          if (!bl) {
            model.fireSmokeDetectModel.value?.fireEnable.value = enable ? 0 : 1;
            model.fireSmokeDetectModel.value?.smokeEnable.value =
                enable ? 0 : 1;
            return false;
          } else {
            return true;
          }
        }
        break;
    }
    return false;
  }

  Widget switchWidget(AiType type, {String from = "", String tagN = ""}) {
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return Switch(value: true, onChanged: (value) {});
    switch (type) {
      case AiType.areaIntrusion:
        return ObxValue<Rx<AreaIntrusionModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) async {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.areaIntrusionModel);
      case AiType.personStay:
        return ObxValue<Rx<PersonStayModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) async {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.personStayModel);
      case AiType.illegalParking:
        return ObxValue<Rx<IllegalParkingModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.illegalParkingModel);
      case AiType.crossBorder:
        return ObxValue<Rx<CrossBorderModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.crossBorderModel);
      case AiType.offPostMonitor:
        return ObxValue<Rx<OffPostMonitorModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.offPostMonitorModel);
      case AiType.carRetrograde:
        return ObxValue<Rx<CarRetrogradeModel?>>((data) {
          return Switch(
              value: data.value?.enable.value == 1,
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.carRetrogradeModel);
      case AiType.packageDetect:
        return ObxValue<Rx<PackageDetectModel?>>((data) {
          return Switch(
              value: (data.value?.disappearEnable.value == 1) ||
                  (data.value?.appearEnable.value == 1) ||
                  (data.value?.stayEnable.value == 1),
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.packageDetectModel);
      case AiType.fireSmokeDetect:
        return ObxValue<Rx<FireSmokeDetectModel?>>((data) {
          return Switch(
              value: (data.value?.smokeEnable.value == 1) ||
                  (data.value?.fireEnable.value == 1),
              onChanged: (value) {
                switchChange(type, value, from: from, tagN: tagN);
              });
        }, model.fireSmokeDetectModel);
      case AiType.none:
        // TODO: Handle this case.
        break;
    }
    return Switch(value: true, onChanged: (value) {});
  }

  void switchChange(AiType type, bool value,
      {String from = "", String tagN = ""}) async {
    if (tagN == "已过期" || tagN == "未开通") {
      EasyLoading.showToast("请先开通该功能！");
      return;
    }
    await setSwitchValue(value, type, from);
  }

  Future<void> setSwitchValue(bool value, AiType type, String from) async {
    bool bl = await controlDetectSwitch(value, type);
    if (from.length != 0 && bl) {
      AIDetectSettingLogic settingsLogic = Get.find<AIDetectSettingLogic>();
      settingsLogic.state!.currentPackageIndex.value = 0;
      settingsLogic.state!.currentFireSmokeIndex.value = 0;
      settingsLogic.state!.isShow.value = true;
      settingsLogic.initIsOpen();
    }
  }
}
