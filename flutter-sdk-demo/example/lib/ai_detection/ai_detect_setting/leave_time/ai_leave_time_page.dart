import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_leave_time_logic.dart';

class AILeaveTimePage<S> extends GetWidgetView<AILeaveTimeLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("离岗时间："),
        InkWell(
            onTap: () {
              _showLeaveTimeBottomSheep();
            },
            child: ObxValue<RxInt>((data) {
              String name = "${data.value} 秒";
              return Text("$name >>");
            }, controller.state!.leaveTime))
      ]),
    );
  }

  void _showLeaveTimeBottomSheep() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("离岗时间设置："),
                  SizedBox(height: 20),
                  TextField(
                    controller: controller.leaveTimeController,
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
                            controller.setLeaveTime();
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
