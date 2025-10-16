import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_target_type_logic.dart';

class AITargetTypePage<S> extends GetWidgetView<AITargetTypeLogic, S> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text("目标类型："),
      InkWell(
          onTap: () {
            _showTargetTypeBottomSheep();
          },
          child: ObxValue<RxInt>((data) {
            String name = controller.getSelectedName(data.value);
            return Text("$name");
          }, controller.state!.targetType))
    ]);
  }

  void _showTargetTypeBottomSheep() {
    controller.initTargetState();
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("目标类型："),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: () {
                            controller.state!.target0Selected.value =
                                !controller.state!.target0Selected.value;
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("人",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.blue
                                        : Colors.black));
                          }, controller.state!.target0Selected)),
                      InkWell(
                          onTap: () {
                            controller.state!.target1Selected.value =
                                !controller.state!.target1Selected.value;
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("车",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.blue
                                        : Colors.black));
                          }, controller.state!.target1Selected)),
                      InkWell(
                          onTap: () {
                            controller.state!.target2Selected.value =
                                !controller.state!.target2Selected.value;
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("宠物",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.blue
                                        : Colors.black));
                          }, controller.state!.target2Selected)),
                    ],
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      controller.setTargetType();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: Text(
                        '确定'.tr,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}
