import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/utils/app_page_view.dart';

import 'ai_fire_smoke_scene_logic.dart';

class AIFireSmokeScenePage<S> extends GetWidgetView<AIFireSmokeSceneLogic, S> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showSceneBottomSheep();
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("使用场景："),
        ObxValue<RxInt>((data) {
          String name = "室内";
          if (data.value == 0) {
            name = "室内";
          } else {
            name = "室外";
          }
          return Text("$name");
        }, controller.state!.fireSmokeScene)
      ]),
    );
  }

  void _showSceneBottomSheep() {
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
                        controller.setFireSmokeScene(0);
                      },
                      child: ObxValue<RxInt>((data) {
                        return Text("室内",
                            style: TextStyle(
                                fontSize: 18,
                                color: data.value == 0
                                    ? Colors.blue
                                    : Colors.black));
                      }, controller.state!.fireSmokeScene)),
                  Divider(),
                  InkWell(
                      onTap: () {
                        controller.setFireSmokeScene(1);
                      },
                      child: ObxValue<RxInt>((data) {
                        return Text("室外",
                            style: TextStyle(
                                fontSize: 18,
                                color: data.value == 1
                                    ? Colors.blue
                                    : Colors.black));
                      }, controller.state!.fireSmokeScene)),
                ],
              ));
        });
  }
}
