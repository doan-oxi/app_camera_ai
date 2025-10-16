import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/package/package_logic.dart';
import 'package:vsdk_example/utils/app_page_view.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../../../utils/manager.dart';
import '../ai_detect_setting_logic.dart';

class AIPackagePage<S> extends GetWidgetView<AIPackageLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      packageItemWidget("有包裹出现", 0),
      packageItemWidget("有包裹消失", 1),
      packageItemWidget("有包裹滞留", 2),
    ]);
  }

  Widget packageItemWidget(String name, int index) {
    return InkWell(
      onTap: () {
        controller.state!.currentPackageIndex.value = index;
        controller.setIsShow(index);
        AIDetectSettingLogic settingsLogic = Get.find<AIDetectSettingLogic>();
        settingsLogic.reGetInfo();
      },
      child: ObxValue<RxInt>((data) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
                color: data.value == index ? Colors.blue : Colors.grey,
                width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              Switch(
                  value: index == 0
                      ? Manager()
                              .getDeviceManager()
                              ?.deviceModel
                              ?.packageDetectModel
                              .value
                              ?.appearEnable
                              .value ==
                          1
                      : index == 1
                          ? Manager()
                                  .getDeviceManager()
                                  ?.deviceModel
                                  ?.packageDetectModel
                                  .value
                                  ?.disappearEnable
                                  .value ==
                              1
                          : Manager()
                                  .getDeviceManager()
                                  ?.deviceModel
                                  ?.packageDetectModel
                                  .value
                                  ?.stayEnable
                                  .value ==
                              1,
                  onChanged: (value) {
                    controller.setSwitch(value, index);
                  })
            ],
          ),
        );
      }, controller.state!.currentPackageIndex),
    );
  }
}
