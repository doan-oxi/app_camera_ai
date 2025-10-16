import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/app_routes.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../model/device_model.dart';
import '../utils/manager.dart';
import 'ai_detect_model.dart';
import 'ai_detect_setting/ai_detect_setting_conf.dart';
import 'ai_detection_logic.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AIDetectionPage extends GetView<AIDetectionLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('AI 智能服务'),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: ObxValue<RxInt>((data) {
                return data.value != 0
                    ? Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportAreaIntrusion
                                .value,
                            child: detectionItemWidget(
                                context, "区域入侵", AiType.areaIntrusion),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportPersonStay
                                .value,
                            child: detectionItemWidget(
                                context, "人员逗留监测", AiType.personStay),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportIllegalParking
                                .value,
                            child: detectionItemWidget(
                                context, "车辆违停监测", AiType.illegalParking),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportCrossBorder
                                .value,
                            child: detectionItemWidget(
                                context, "越界监测", AiType.crossBorder),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportOffPostMonitor
                                .value,
                            child: detectionItemWidget(
                                context, "离岗监测", AiType.offPostMonitor),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportCarRetrograde
                                .value,
                            child: detectionItemWidget(
                                context, "车辆逆行监测", AiType.carRetrograde),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportPackageDetect
                                .value,
                            child: detectionItemWidget(
                                context, "包裹识别", AiType.packageDetect),
                          ),
                          Visibility(
                            visible: Manager()
                                .getDeviceManager()!
                                .deviceModel!
                                .isSupportFireSmokeDetect
                                .value,
                            child: detectionItemWidget(
                                context, "火灾监测", AiType.fireSmokeDetect),
                          ),
                        ],
                      )
                    : SizedBox();
              }, controller.state!.aiGet),
            ),
          )),
    );
  }

  Widget detectionItemWidget(BuildContext context, String name, AiType type) {
    String tagName = "未开通";
    Color color = Colors.grey;
    DeviceModel? model = Manager().getDeviceManager()?.deviceModel;
    if (model == null) return SizedBox();
    switch (type) {
      case AiType.areaIntrusion:
        if (model.areaIntrusionFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.areaIntrusionFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.areaIntrusionFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.areaIntrusionFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.personStay:
        if (model.personStayFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.personStayFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.personStayFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.personStayFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.illegalParking:
        if (model.illegalParkingFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.illegalParkingFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.illegalParkingFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.illegalParkingFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.crossBorder:
        if (model.crossBorderModelFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.crossBorderModelFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.crossBorderModelFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.crossBorderModelFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.offPostMonitor:
        if (model.offPostMonitorFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.offPostMonitorFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.offPostMonitorFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.offPostMonitorFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.carRetrograde:
        if (model.carRetrogradeModelFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.carRetrogradeModelFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.carRetrogradeModelFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.carRetrogradeModelFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.packageDetect:
        if (model.packageDetectModelFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.packageDetectModelFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.packageDetectModelFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.packageDetectModelFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.fireSmokeDetect:
        if (model.fireSmokeDetectModelFunctionStatus.value == 0) {
          tagName = "未开通";
          color = Colors.grey;
        } else if (model.fireSmokeDetectModelFunctionStatus.value == 1) {
          tagName = "试用中";
          color = Colors.blue;
        } else if (model.fireSmokeDetectModelFunctionStatus.value == 2) {
          tagName = "已开通";
          color = Colors.white;
        } else if (model.fireSmokeDetectModelFunctionStatus.value == 3) {
          tagName = "已过期";
          color = Colors.red;
        }
        break;
      case AiType.none:
        // TODO: Handle this case.
        break;
    }
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
      color: Colors.grey[300],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: color),
                child: Text(tagName,
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
              controller.switchWidget(type, tagN: tagName)
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
              InkWell(
                  onTap: () {
                    if (tagName == "已过期" || tagName == "未开通") {
                      EasyLoading.showToast("请先开通该功能！");
                      return;
                    }
                    Get.toNamed(AppRoutes.aiDetectSetting,
                        arguments: AIDetectSettingArgs(type));
                  },
                  child: Icon(Icons.settings))
            ],
          ),
        ],
      ),
    );
  }
}
