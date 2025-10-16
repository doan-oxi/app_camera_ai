import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_package_stay_time_logic.dart';

class AIPackageStayTimePage<S>
    extends GetWidgetView<AIPackageStayTimeLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("包裹滞留时间："),
        InkWell(
            onTap: () {
              showStayTimeBottomSheep();
            },
            child: ObxValue<RxInt>((data) {
              String name = controller.getStayTimeName(data.value);
              return Text("$name >>");
            }, controller.state!.stayTimeIndex))
      ]),
    );
  }

  void showStayTimeBottomSheep() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  timeWidget("10分钟", 0),
                  SizedBox(height: 20),
                  timeWidget("30分钟", 1),
                  SizedBox(height: 20),
                  timeWidget("1小时", 2),
                  SizedBox(height: 20),
                  timeWidget("6小时", 3),
                  SizedBox(height: 20),
                  timeWidget("12小时", 4),
                  SizedBox(height: 20),
                  timeWidget("24小时", 5),
                  SizedBox(height: 20),
                  timeWidget("48小时", 6),
                  SizedBox(height: 20),
                  timeWidget("72小时", 7),
                ],
              ));
        });
  }

  Widget timeWidget(String time, int index) {
    return InkWell(
        onTap: () {
          controller.state!.stayTimeIndex.value = index;
          controller.setTime(index);
        },
        child: ObxValue<RxInt>((data) {
          return Text(time,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: data.value == index ? Colors.blue : Colors.black));
        }, controller.state!.stayTimeIndex));
  }
}
