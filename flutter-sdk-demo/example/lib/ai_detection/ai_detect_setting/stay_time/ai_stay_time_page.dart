import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_stay_time_logic.dart';

class AIStayTimePage<S> extends GetWidgetView<AIStayTimeLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ObxValue<Rx<AiType?>>((data) {
          return Text(data.value == AiType.personStay ? "人员逗留时间：" : "车辆违停时间：");
        }, controller.state!.aiType),
        InkWell(
            onTap: () {
              _showStayTimeBottomSheep();
            },
            child: ObxValue<RxInt>((data) {
              String name = "${data.value} 秒";
              return Text("$name >>");
            }, controller.state!.stayTime))
      ]),
    );
  }

  void _showStayTimeBottomSheep() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ObxValue<Rx<AiType?>>((data) {
                    return Text(data.value == AiType.personStay
                        ? "逗留时间设置："
                        : "违停时间设置：");
                  }, controller.state!.aiType),
                  SizedBox(height: 20),
                  TextField(
                    controller: controller.timeTextController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '请输入时间',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("可设置30-3600秒"),
                  SizedBox(height: 30.0),
                  Divider(
                    height: 1,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            child: Text(
                              '取消'.tr,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            left: Divider.createBorderSide(context,
                                color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            controller.setStayTime();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            child: Text(
                              '确定'.tr,
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ));
        });
  }
}
