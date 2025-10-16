import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';
import 'package:vsdk_example/utils/device_manager.dart';

import '../../../utils/manager.dart';
import '../ai_detect_setting_logic.dart';
import 'fire_smoke_logic.dart';

class AIFireSmokePage<S> extends GetWidgetView<AIFireSmokeLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      itemWidget("火灾监测", 0),
      itemWidget("烟雾监测", 1),
    ]);
  }

  Widget itemWidget(String name, int index) {
    return InkWell(
      onTap: () {
        controller.state!.currentFireSmokeIndex.value = index;
        controller.setShow(index);
        AIDetectSettingLogic settingsLogic = Get.find<AIDetectSettingLogic>();
        settingsLogic.reGetInfo();
      },
      child: ObxValue<RxInt>((data) {
        return Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
                color: data.value == index ? Colors.blue : Colors.grey,
                width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(name),
              Switch(
                  value: index == 0
                      ? Manager()
                              .getDeviceManager()
                              ?.deviceModel
                              ?.fireSmokeDetectModel
                              .value
                              ?.fireEnable
                              .value ==
                          1
                      : Manager()
                              .getDeviceManager()
                              ?.deviceModel
                              ?.fireSmokeDetectModel
                              .value
                              ?.smokeEnable
                              .value ==
                          1,
                  onChanged: (value) {
                    controller.setFireSmokeSwitch(value, index);
                  })
            ],
          ),
        );
      }, controller.state!.currentFireSmokeIndex),
    );
  }
}
