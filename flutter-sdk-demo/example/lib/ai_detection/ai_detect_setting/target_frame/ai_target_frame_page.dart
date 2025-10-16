import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_target_frame_logic.dart';

class AITargetFramePage<S> extends GetWidgetView<AITargetFrameLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("目标框和侦测规则显示："),
      ObxValue<RxInt>((data) {
        return data.value != -1
            ? Switch(
                value: controller.getTargetSwitchStatus(),
                onChanged: (value) {
                  controller.controlTargetSwitch(
                      value, controller.state!.aiType.value!);
                })
            : Text("出错了");
      }, controller.state!.targetFlag)
    ]);
  }
}
