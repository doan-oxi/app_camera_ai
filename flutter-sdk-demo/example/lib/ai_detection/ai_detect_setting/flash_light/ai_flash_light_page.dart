import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_flash_light_logic.dart';

class AIFlashLightPage<S> extends GetWidgetView<AIFlashLightLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("报警闪光灯："),
      ObxValue<RxInt>((data) {
        return data.value != -1
            ? Switch(
                value: controller.getSwitchStatus(),
                onChanged: (value) {
                  controller.controlFlashLightSwitch(
                      value, controller.state!.aiType.value!);
                })
            : Text("出错了");
      }, controller.state!.flashFlag)
    ]);
  }
}
