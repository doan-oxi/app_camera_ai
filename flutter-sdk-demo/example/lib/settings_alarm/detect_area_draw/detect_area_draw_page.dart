import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk/app_player.dart';

import '../../utils/device_manager.dart';
import '../../utils/manager.dart';
import '../../widget/other/grid_painter_widget.dart';
import '../../widget/virtual_three_view.dart';
import 'detect_area_draw_logic.dart';

class DetectAreaDrawPage extends GetView<DetectAreaDrawLogic> {
  @override
  Widget build(BuildContext context) {
    double aWidth = MediaQuery.of(context).size.width;
    double aHeight = aWidth * 9 / 16;
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('侦测区域绘制'),
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text("球机："),

                  ///单目
                  Stack(
                    children: [
                      Manager()
                                  .getDeviceManager()!
                                  .deviceModel!
                                  .splitScreen
                                  .value ==
                              2
                          ? VirtualThreeView(
                              child: AppPlayerView(
                                controller:
                                    Manager().getDeviceManager()!.controller!,
                              ),
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width,
                              height:
                                  MediaQuery.of(context).size.width * 9 / 16,
                            )
                          : AspectRatio(
                              aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                              child: AppPlayerView(
                                controller:
                                    Manager().getDeviceManager()!.controller!,
                              ),
                            ),
                      Obx(() {
                        return GridPainter(aWidth, aHeight, (data) {
                          ///保存数据
                          controller.save(data);
                        }, controller.state!.gridState.value);
                      })
                    ],
                  ),

                  SizedBox(height: 10),

                  ///4目（顺时针）
                  Visibility(
                    visible: Manager()
                            .getDeviceManager()!
                            .deviceModel!
                            .supportMutilSensorStream
                            .value ==
                        4,
                    child: Stack(
                      children: [
                        Manager()
                                    .getDeviceManager()!
                                    .deviceModel!
                                    .splitScreen
                                    .value ==
                                2
                            ? VirtualThreeView(
                                child: AppPlayerView(
                                  controller:
                                      Manager().getDeviceManager()!.controller!,
                                ),
                                alignment: Alignment.centerRight,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width * 9 / 16,
                              )
                            : Manager().getDeviceManager()!.controller3 == null
                                ? SizedBox()
                                : AspectRatio(
                                    aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                                    child: AppPlayerView(
                                      controller: Manager()
                                          .getDeviceManager()!
                                          .controller3!,
                                    ),
                                  ),
                        Obx(() {
                          return GridPainter(aWidth, aHeight, (data) {
                            ///保存数据
                            controller.save(data, index: 1);
                          }, controller.state!.gridState3.value);
                        })
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("枪击："),

                  ///2目
                  Visibility(
                    visible: Manager()
                            .getDeviceManager()!
                            .deviceModel!
                            .supportMutilSensorStream
                            .value >=
                        1,
                    child: Stack(
                      children: [
                        (Manager()
                                        .getDeviceManager()!
                                        .deviceModel!
                                        .splitScreen
                                        .value ==
                                    1 ||
                                Manager()
                                        .getDeviceManager()!
                                        .deviceModel!
                                        .splitScreen
                                        .value ==
                                    2)
                            ? Manager().getDeviceManager()!.controller1 == null
                                ? SizedBox()
                                : VirtualThreeView(
                                    child: AppPlayerView(
                                      controller: Manager()
                                          .getDeviceManager()!
                                          .controller1!,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width *
                                        9 /
                                        16,
                                  )
                            : Manager().getDeviceManager()!.controller1 == null
                                ? SizedBox()
                                : AspectRatio(
                                    aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                                    child: AppPlayerView(
                                      controller: Manager()
                                          .getDeviceManager()!
                                          .controller1!,
                                    ),
                                  ),
                        Obx(() {
                          return GridPainter(aWidth, aHeight, (data) {
                            ///保存数据
                            if (Manager()
                                    .getDeviceManager()!
                                    .deviceModel!
                                    .supportMutilSensorStream
                                    .value >=
                                4) {
                              controller.save(data, index: 3);
                            } else {
                              controller.save(data, index: 1);
                            }
                          }, controller.state!.gridState1.value);
                        })
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  ///真三目或假三目
                  Visibility(
                    visible: Manager()
                            .getDeviceManager()!
                            .deviceModel!
                            .supportMutilSensorStream
                            .value >=
                        3,
                    child: Stack(
                      children: [
                        Manager()
                                    .getDeviceManager()!
                                    .deviceModel!
                                    .splitScreen
                                    .value ==
                                1
                            ? Manager().getDeviceManager()!.controller1 == null
                                ? SizedBox()
                                : VirtualThreeView(
                                    child: AppPlayerView(
                                      controller: Manager()
                                          .getDeviceManager()!
                                          .controller1!,
                                    ),
                                    alignment: Alignment.centerRight,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width *
                                        9 /
                                        16,
                                  )
                            : Manager().getDeviceManager()!.controller2 == null
                                ? SizedBox()
                                : AspectRatio(
                                    aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                                    child: AppPlayerView(
                                      controller: Manager()
                                          .getDeviceManager()!
                                          .controller2!,
                                    ),
                                  ),
                        Obx(() {
                          return GridPainter(aWidth, aHeight, (data) {
                            ///保存数据
                            if (Manager()
                                    .getDeviceManager()!
                                    .deviceModel!
                                    .splitScreen
                                    .value ==
                                1) {
                              controller.save(data, index: 1);
                            } else {
                              controller.save(data, index: 2);
                            }
                          }, controller.state!.gridState2.value);
                        })
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
