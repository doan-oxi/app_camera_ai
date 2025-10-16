import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/ai_detection/ai_detect_setting/alarm_sound/voice_sound_model.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_alarm_sound_logic.dart';

class AIAlarmSoundPage<S> extends GetWidgetView<AIAlarmSoundLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("设备报警声："),
      ObxValue<Rx<DeviceSoundModel?>>((data){
        return data.value!=null?Switch(
            value: data.value?.isOpen == "1",
            onChanged: (value) {
              controller.openOrCloseVoice(value ? 1 : 0);
            }): Text("获取失败");
      },controller.state!.deviceSoundModel)
    ]);
  }
}
