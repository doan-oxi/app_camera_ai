import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';
import 'ai_sensitivity_logic.dart';

class AISensitivityPage<S> extends GetWidgetView<AISensitivityLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("侦测灵敏度："),
      SizedBox(
        height: 10,
      ),
      Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("低"),
                  Text("中"),
                  Text("高"),
                ],
              ),
            ),
            Container(
                child: ObxValue<RxInt>((data) {
              return data.value != -1
                  ? Slider(
                      min: 1,
                      max: 3,
                      divisions: 2,
                      value: controller.getSensitivityValue().toDouble(),
                      onChanged: (value) {
                        print("value:${value.toInt()}");
                        controller.controlSensitivity(
                            value.toInt(), controller.state!.aiType.value!);
                      },
                    )
                  : Text("出错了");
            }, controller.state!.sensitivityFlag))
          ],
        ),
      )
    ]);
  }
}
