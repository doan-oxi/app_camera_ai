import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_alarm_plan_logic.dart';

class AIAlarmPlanPage<S> extends GetWidgetView<AIAlarmPlanLogic, S> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showAiDetectTimeSheet();
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("智能侦测定时："),
        ObxValue<RxInt>((data) {
          String name = "全天侦测";
          if (data.value == 1) {
            name = "白天侦测";
          } else if (data.value == 2) {
            name = "夜间侦测";
          } else if (data.value == 3) {
            name = "自定义时间";
          } else {
            name = "全天侦测";
          }
          return Text("$name");
        }, controller.state!.alarmPlan)
      ]),
    );
  }

  ///智能侦测定时选项
  Widget smartDetectTimeItem(String name, String desc, int index) {
    return InkWell(
      onTap: () {
        controller.setSmartDetect(index);
      },
      child: ObxValue<RxInt>((data) {
        return timeItem(name, desc, data.value == index);
      }, controller.state!.alarmPlan),
    );
  }

  ///智能侦测定时
  void showAiDetectTimeSheet() {
    // controller.initSmartTimePlan();
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Container(
              height: 300,
              margin: EdgeInsets.only(left: 20),
              decoration: BoxDecoration(border: Border(top: BorderSide())),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  smartDetectTimeItem("全天", " (全天24小时智能侦测)", 0),
                  SizedBox(height: 20),
                  smartDetectTimeItem("仅白天", " (早8:00-晚20:00启动)", 1),
                  SizedBox(height: 20),
                  smartDetectTimeItem("仅夜间", " (晚20:00-次日早8:00启动)", 2),
                  SizedBox(height: 20),
                  smartDetectTimeItem("自定义", " (自定义-如：9:30-17:30，周一、三、五)", 3),
                  SizedBox(height: 30),
                  InkWell(
                      onTap: () {
                        //保存
                        controller.setMotionSmartDetectTime();
                      },
                      child: Text("保存"))
                ],
              ));
        });
  }

  Widget timeItem(String name, String desc, bool isSelected) {
    return Row(
      children: [
        Icon(Icons.circle, color: isSelected ? Colors.blue : Colors.grey),
        SizedBox(
          width: 6,
        ),
        Text(name,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        Text(desc,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400))
      ],
    );
  }
}
