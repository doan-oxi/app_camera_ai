import 'package:vsdk/camera_device/camera_device.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../../../app_routes.dart';
import '../../../model/device_model.dart';
import '../../../model/plan_model.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../../ai_detection_logic.dart';
import '../ai_detect_setting_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

mixin AIAlarmPlanLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIAlarmPlanLogic>(this);
    super.initPut();
  }

  List records = [];

  void setSmartDetect(int index) async {
    state!.alarmPlan(index);
    if (index == 0) {
      //全天
      if (records.length < 21) {
        int num = 21 - records.length;
        for (int i = 0; i < num; i++) {
          records.add(-1);
        }
      }
    } else if (index == 1) {
      //白天
      int startTime = 480;
      int endTime = 1200;
      List weeks = [7, 1, 2, 3, 4, 5, 6];
      records = getRecords(startTime, endTime, weeks);
    } else if (index == 2) {
      //夜间
      int startTime = 1200;
      int endTime = 480;
      List weeks = [7, 1, 2, 3, 4, 5, 6];
      records = getRecords(startTime, endTime, weeks);
    } else {
      //自定义，demo 时间为早9:30-下午5:30，周一、周三、周五
      int startTime = 9 * 60 + 30;
      int endTime = 17 * 60 + 30;
      List weeks = [1, 3, 5];
      records = getRecords(startTime, endTime, weeks);
    }
  }

  var actionPlans;

  List getRecords(int startTime, int endTime, List<dynamic> weeks) {
    PlanModel model = PlanModel.fromPlans(
        startTime, endTime, weeks, Manager().getCurrentUid());
    actionPlans = <PlanModel>[];
    actionPlans.add(model);
    List records = [];
    actionPlans.forEach((element) {
      records.add(element.sum);
    });
    if (records.length < 21) {
      int num = 21 - records.length;
      for (int i = 0; i < num; i++) {
        records.add(-1);
      }
    }
    return records;
  }

  Future<void> setMotionSmartDetectTime() async {
    if (state!.alarmPlan.value == 0) {
      records.clear();
      for (int i = 0; i < 21; i++) {
        records.add(-1);
      }
    }
    int type = 14;
    switch (state!.aiType.value) {
      case AiType.fireSmokeDetect:
        type = 12;
        break;
      case AiType.areaIntrusion:
        type = 14;
        break;
      case AiType.personStay:
        type = 15;
        break;
      case AiType.illegalParking:
        type = 16;
        break;
      case AiType.crossBorder:
        type = 17;
        break;
      case AiType.offPostMonitor:
        type = 18;
        break;
      case AiType.carRetrograde:
        type = 19;
        break;
      case AiType.packageDetect:
        type = 20;
        break;
    }
    bool bl = await Manager()
            .getDeviceManager()
            ?.mDevice!
            .aiDetect
            ?.configAiDetectPlan(type, records: records, enable: 1) ??
        false;

    if (bl) {
      if (actionPlans != null) {
        DeviceModel? deviceModel = Manager().getDeviceManager()?.deviceModel;
        if (deviceModel == null) return;
        switch (state!.aiType.value) {
          case AiType.areaIntrusion:
            deviceModel.actionPlansAreaIntrusion.value = actionPlans;
            break;
          case AiType.personStay:
            deviceModel.actionPlansPersonStay.value = actionPlans;
            break;
          case AiType.illegalParking:
            deviceModel.actionPlansIllegalParking.value = actionPlans;
            break;
          case AiType.crossBorder:
            deviceModel.actionPlansCrossBorder.value = actionPlans;
            break;
          case AiType.offPostMonitor:
            deviceModel.actionPlansOffPostMonitor.value = actionPlans;
            break;
          case AiType.carRetrograde:
            deviceModel.actionPlansCarRetrograde.value = actionPlans;
            break;
          case AiType.packageDetect:
            deviceModel.actionPlansPackageDetect.value = actionPlans;
            break;
          case AiType.fireSmokeDetect:
            deviceModel.actionFirePlans.value = actionPlans;
            break;
          default:
            break;
        }
      }
      EasyLoading.showToast("保存成功");
      Get.back();
    }
  }

  void getAiMotionAlarmPlan() async {
    CameraDevice? basisDevice = Manager().getDeviceManager()?.mDevice;
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (basisDevice == null || model == null) return;
    int type = 14;
    switch (state!.aiType.value) {
      case AiType.fireSmokeDetect:
        type = 12;
        break;
      case AiType.areaIntrusion:
        type = 14;
        break;
      case AiType.personStay:
        type = 15;
        break;
      case AiType.illegalParking:
        type = 16;
        break;
      case AiType.crossBorder:
        type = 17;
        break;
      case AiType.offPostMonitor:
        type = 18;
        break;
      case AiType.carRetrograde:
        type = 19;
        break;
      case AiType.packageDetect:
        type = 20;
        break;
      default:
        break;
    }

    bool bl = await basisDevice.aiDetect?.getAiDetectPlan(type) ?? false;
    if (bl == true) {
      var typeString;
      switch (state!.aiType.value) {
        case AiType.fireSmokeDetect:
          typeString = 'fire';

          Map? planMap = basisDevice.aiDetect?.firePlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionFirePlans.clear();
          model.fire_plan_enable.value = enable;
          if (planModels.isEmpty) {
            model.has_fire_plan.value = false;
          } else {
            model.has_fire_plan.value = true;
          }
          model.actionFirePlans.addAll(planModels);
          break;
        case AiType.areaIntrusion:
          typeString = 'region_entry';

          Map? planMap = basisDevice.aiDetect?.areaIntrusionPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansAreaIntrusion.clear();
          model.areaIntrusionPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasAreaIntrusionPlan.value = false;
          } else {
            model.hasAreaIntrusionPlan.value = true;
          }
          model.actionPlansAreaIntrusion.addAll(planModels);
          break;
        case AiType.personStay:
          typeString = 'person_stay';
          Map? planMap = basisDevice.aiDetect?.personStayPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansPersonStay.clear();
          model.personStayPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasPersonStayPlan.value = false;
          } else {
            model.hasPersonStayPlan.value = true;
          }
          model.actionPlansPersonStay.addAll(planModels);
          break;
        case AiType.illegalParking:
          typeString = 'car_stay';

          Map? planMap = basisDevice.aiDetect?.illegalParkingPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansIllegalParking.clear();
          model.illegalParkingPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasIllegalParkingPlan.value = false;
          } else {
            model.hasIllegalParkingPlan.value = true;
          }
          model.actionPlansIllegalParking.addAll(planModels);
          break;
        case AiType.crossBorder:
          typeString = 'line_cross';

          Map? planMap = basisDevice.aiDetect?.crossBorderPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansCrossBorder.clear();
          model.crossBorderPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasCrossBorderPlan.value = false;
          } else {
            model.hasCrossBorderPlan.value = true;
          }
          model.actionPlansCrossBorder.addAll(planModels);
          break;
        case AiType.offPostMonitor:
          typeString = 'person_onduty';

          Map? planMap = basisDevice.aiDetect?.offPostMonitorPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansOffPostMonitor.clear();
          model.offPostMonitorPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasOffPostMonitorPlan.value = false;
          } else {
            model.hasOffPostMonitorPlan.value = true;
          }
          model.actionPlansOffPostMonitor.addAll(planModels);

          break;
        case AiType.carRetrograde:
          typeString = 'car_retrograde';

          Map? planMap = basisDevice.aiDetect?.carRetrogradePlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansCarRetrograde.clear();
          model.carRetrogradePlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasCarRetrogradePlan.value = false;
          } else {
            model.hasCarRetrogradePlan.value = true;
          }
          model.actionPlansCarRetrograde.addAll(planModels);
          break;
        case AiType.packageDetect:
          typeString = 'package_detect';

          Map? planMap = basisDevice.aiDetect?.packageDetectPlanData;
          int enable = 0;
          List<PlanModel> planModels = [];
          if (planMap != null) {
            enable = int.tryParse(planMap["${typeString}_plan_enable"]) ?? 0;
            for (int i = 1; i <= 21; i++) {
              String value = planMap["${typeString}_plan$i"];
              int num = int.tryParse(value) ?? 0;
              if (num != 0 && num != -1 && num != 1) {
                PlanModel model = PlanModel.fromCgi(num);
                planModels.add(model);
              }
            }
          }
          model.actionPlansPackageDetect.clear();
          model.packageDetectPlanEnable.value = enable;
          if (planModels.isEmpty) {
            model.hasPackageDetectPlan.value = false;
          } else {
            model.hasPackageDetectPlan.value = true;
          }
          model.actionPlansPackageDetect.addAll(planModels);
          break;
        default:
          break;
      }
    }
    initAlarmPlanOption();
  }

  initAlarmPlanOption() {
    state!.alarmPlan(0);
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return;
    var actionPlans;
    switch (state!.aiType.value) {
      case AiType.fireSmokeDetect:
        if (model.actionFirePlans.isNotEmpty) {
          actionPlans = model.actionFirePlans;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.areaIntrusion:
        if (model.actionPlansAreaIntrusion.isNotEmpty) {
          actionPlans = model.actionPlansAreaIntrusion;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.personStay:
        if (model.actionPlansPersonStay.isNotEmpty) {
          actionPlans = model.actionPlansPersonStay;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.illegalParking:
        if (model.actionPlansIllegalParking.isNotEmpty) {
          actionPlans = model.actionPlansIllegalParking;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.crossBorder:
        if (model.actionPlansCrossBorder.isNotEmpty) {
          actionPlans = model.actionPlansCrossBorder;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.offPostMonitor:
        if (model.actionPlansOffPostMonitor.isNotEmpty) {
          actionPlans = model.actionPlansOffPostMonitor;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.carRetrograde:
        if (model.actionPlansCarRetrograde.isNotEmpty) {
          actionPlans = model.actionPlansCarRetrograde;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      case AiType.packageDetect:
        if (model.actionPlansPackageDetect.isNotEmpty) {
          actionPlans = model.actionPlansPackageDetect;
          initAlarmPlanIndex(actionPlans);
        }
        break;
      default:
        break;
    }
  }

  void initAlarmPlanIndex(actionPlans) {
    if (actionPlans.length == 1) {
      PlanModel model = actionPlans[0];
      if ((model.startTime ?? "00:00") == "08:00" &&
          (model.endTime ?? "23:59") == "20:00") {
        //白天
        state!.alarmPlan(1);
      } else if ((model.startTime ?? "00:00") == "20:00" &&
          (model.endTime ?? "23:59") == "08:00") {
        //夜间
        state!.alarmPlan(2);
      } else {
        //自定义
        state!.alarmPlan(3);
      }
    }
  }
}
