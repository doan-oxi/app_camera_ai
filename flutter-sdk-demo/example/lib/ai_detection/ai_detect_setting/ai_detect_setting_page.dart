import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/flash_light/ai_flash_light_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/leave_time/ai_leave_time_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/package_stay_time/ai_package_stay_time_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/person_count/ai_person_count_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/sensitivity/ai_sensitivity_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/stay_time/ai_stay_time_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/target_frame/ai_target_frame_page.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/target_type/ai_target_type_page.dart';
import 'package:vsdk_example/app_routes.dart';

import '../../model/device_model.dart';
import '../ai_detection_logic.dart';
import 'ai_detect_setting_logic.dart';
import 'ai_detect_setting_state.dart';
import 'alarm_plan/ai_alarm_plan_page.dart';
import 'alarm_sound/ai_alarm_sound_page.dart';
import 'area_draw/area_draw_conf.dart';
import 'fire_smoke/fire_smoke_page.dart';
import 'fire_smoke_scene/ai_fire_smoke_scene_page.dart';
import 'package/package_page.dart';

class AIDetectSettingPage extends GetView<AIDetectSettingLogic> {
  @override
  Widget build(BuildContext context) {
    AIDetectionLogic aiDetectionLogic = Get.find<AIDetectionLogic>();
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('${controller.name}设置'),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Container(
                child: ObxValue<RxBool>((data) {
                  return Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(controller.name),
                          aiDetectionLogic.switchWidget(
                              controller.state!.aiType.value!,
                              from: "Setting")
                        ]),
                    Divider(),
                    Visibility(
                        visible: data.value == true &&
                            ((controller.state!.aiType.value ==
                                    AiType.areaIntrusion) ||
                                (controller.state!.aiType.value ==
                                    AiType.crossBorder)),
                        child: AITargetTypePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                    AiType.areaIntrusion ||
                                controller.state!.aiType.value ==
                                    AiType.crossBorder),
                        child: Divider()),
                    Visibility(
                        visible: data.value == true,
                        child: AITargetFramePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                    AiType.personStay ||
                                controller.state!.aiType.value ==
                                    AiType.offPostMonitor),
                        child: Divider()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                    AiType.personStay ||
                                controller.state!.aiType.value ==
                                    AiType.illegalParking),
                        child: AIStayTimePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.offPostMonitor),
                        child: AIPersonCountPage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.offPostMonitor),
                        child: Divider()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.offPostMonitor),
                        child: AILeaveTimePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.packageDetect),
                        child: Divider()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.packageDetect),
                        child: AIPackagePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.fireSmokeDetect),
                        child: AIFireSmokePage<AIDetectSettingState>()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.fireSmokeDetect),
                        child: Divider()),
                    Visibility(
                        visible: (data.value == true) &&
                            (controller.state!.aiType.value ==
                                AiType.fireSmokeDetect),
                        child: AIFireSmokeScenePage<AIDetectSettingState>()),
                    Visibility(
                      visible: (data.value == true) &&
                          (controller.state!.aiType.value ==
                              AiType.packageDetect),
                      child: ObxValue<RxInt>((data) {
                        return data.value == 2
                            ? ObxValue<RxBool>((data) {
                                return Visibility(
                                    visible: data.value,
                                    child: AIPackageStayTimePage<
                                        AIDetectSettingState>());
                              }, controller.state!.isShow)
                            : SizedBox();
                      }, controller.state!.currentPackageIndex),
                    ),
                    Visibility(visible: data.value == true, child: Divider()),
                    Visibility(
                        visible: data.value == true,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(AppRoutes.aiAreaDraw,
                                arguments: AIAreaDrawArgs(
                                    controller.state!.aiType.value!));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text("绘制监测区域："), Text(">>")],
                          ),
                        )),
                    Divider(),
                    Visibility(
                        visible: data.value == true,
                        child: ObxValue<RxBool>((data) {
                          return Visibility(
                              visible: data.value,
                              child: AIAlarmSoundPage<AIDetectSettingState>());
                        }, controller.state!.isShow)),
                    Divider(),
                    Visibility(
                        visible: data.value == true,
                        child: ObxValue<RxBool>((data) {
                          return Visibility(
                              visible: data.value,
                              child: AIFlashLightPage<AIDetectSettingState>());
                        }, controller.state!.isShow)),
                    Divider(),
                    Visibility(
                        visible: data.value == true,
                        child: ObxValue<RxBool>((data) {
                          return Visibility(
                              visible: data.value,
                              child: AIAlarmPlanPage<AIDetectSettingState>());
                        }, controller.state!.isShow)),
                    Divider(),
                    Visibility(
                        visible: data.value == true,
                        child: ObxValue<RxBool>((data) {
                          return Visibility(
                              visible: data.value,
                              child: AISensitivityPage<AIDetectSettingState>());
                        }, controller.state!.isShow))
                  ]);
                }, controller.state!.isOpen),
              ),
            ),
          )),
    );
  }
}
