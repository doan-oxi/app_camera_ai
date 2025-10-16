import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_person_count_logic.dart';

class AIPersonCountPage<S> extends GetWidgetView<AIPersonCountLogic, S> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showCountBottomSheep();
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("最少在岗人数："),
        ObxValue<RxInt>((data) {
          return Text("${data.value} 人");
        }, controller.state!.personCount)
      ]),
    );
  }

  void _showCountBottomSheep() {
    controller.initCountState();
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  InkWell(
                      onTap: () {
                        controller.setCount(1);
                      },
                      child: ObxValue<RxInt>((data) {
                        return Text("1",
                            style: TextStyle(
                                fontSize: 18,
                                color: data.value == 1
                                    ? Colors.blue
                                    : Colors.black));
                      }, controller.state!.personCount)),
                  Divider(),
                  InkWell(
                      onTap: () {
                        controller.setCount(2);
                      },
                      child: ObxValue<RxInt>((data) {
                        return Text("2",
                            style: TextStyle(
                                fontSize: 18,
                                color: data.value == 2
                                    ? Colors.blue
                                    : Colors.black));
                      }, controller.state!.personCount)),
                  Divider(),
                  InkWell(
                      onTap: () {
                        controller.setCount(3);
                      },
                      child: ObxValue<RxInt>((data) {
                        return Text("3",
                            style: TextStyle(
                                fontSize: 18,
                                color: data.value == 3
                                    ? Colors.blue
                                    : Colors.black));
                      }, controller.state!.personCount)),
                ],
              ));
        });
  }
}
