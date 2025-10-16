import 'package:vsdk/app_player.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/widget/draw_area/border_line_widget.dart';

import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../widget/draw_area/car_area_widget.dart';
import '../../../widget/draw_area/dragable_shape_widget.dart';
import 'area_draw_logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiAreaDrawPage extends GetView<AiAreaDrawLogic> {
  @override
  Widget build(BuildContext context) {
    List<Offset> points0 = [
      Offset(0, 0),
      Offset(MediaQuery.of(context).size.width, 0),
      Offset(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      Offset(0, MediaQuery.of(context).size.height),
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('区域绘制'),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            ObxValue<RxInt>((data) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9 / 16,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                      child: AppPlayerView(
                        controller: Manager().getDeviceManager()!.controller!,
                      ),
                    ),
                    Visibility(
                        visible: data.value == 0 &&
                            (controller.state!.aiType.value !=
                                    AiType.crossBorder ||
                                controller.state!.aiType.value !=
                                    AiType.carRetrograde),
                        child: DraggableShape(points0)),
                    Visibility(
                        visible: data.value == 1 &&
                            (controller.state!.aiType.value !=
                                    AiType.crossBorder ||
                                controller.state!.aiType.value !=
                                    AiType.carRetrograde),
                        child: DraggableShape(controller.state!.points1)),
                    Visibility(
                        visible: data.value == 1 &&
                            (controller.state!.aiType.value !=
                                    AiType.crossBorder ||
                                controller.state!.aiType.value !=
                                    AiType.carRetrograde),
                        child: DraggableShape(controller.state!.points2)),

                    ///越界区域，demo的固定坐标是（200,50）,(200,200)
                    Visibility(
                      visible:
                          controller.state!.aiType.value == AiType.crossBorder,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.width * 9 / 16),
                        painter: BorderLineWidget(),
                      ),
                    ),

                    ///车辆逆行，demo的固定坐标是(50,50),(300,50),(300,200),(5,200)
                    Visibility(
                      visible: controller.state!.aiType.value ==
                          AiType.carRetrograde,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.width * 9 / 16),
                        painter: CarAreaWidget(),
                      ),
                    ),
                  ],
                ),
              );
            }, controller.state!.index),
            SizedBox(height: 20),
            Text("Demo为固定区域，具体的区域绘制效果，请自行实现！"),
            SizedBox(height: 20),
            Visibility(
              visible: controller.state!.aiType.value != AiType.crossBorder &&
                  controller.state!.aiType.value != AiType.carRetrograde,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      controller.setAreaDraw(context, 0);
                    },
                    child: ObxValue<RxInt>((data) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: data.value == 0
                                    ? Colors.blue
                                    : Colors.black,
                                width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        alignment: Alignment.center,
                        child: Text("默认全部区域",
                            style: TextStyle(color: Colors.black)),
                      );
                    }, controller.state!.index),
                  ),
                  InkWell(
                    onTap: () {
                      controller.setAreaDraw(context, 1);
                    },
                    child: ObxValue<RxInt>((data) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: data.value == 1
                                    ? Colors.blue
                                    : Colors.black,
                                width: 1),
                            borderRadius: BorderRadius.circular(5)),
                        alignment: Alignment.center,
                        child: Text("保存绘制区域",
                            style: TextStyle(color: Colors.black)),
                      );
                    }, controller.state!.index),
                  )
                ],
              ),
            ),
            Visibility(
              visible: controller.state!.aiType.value == AiType.crossBorder,
              child: InkWell(
                onTap: () {
                  controller.setCrossBorder();
                },
                child: Container(
                  width: 200,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  alignment: Alignment.center,
                  child: Text("保存越界区域", style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            Visibility(
              visible: controller.state!.aiType.value == AiType.carRetrograde,
              child: InkWell(
                onTap: () {
                  controller.setCarArea();
                },
                child: Container(
                  width: 200,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(5)),
                  alignment: Alignment.center,
                  child: Text("保存逆行区域", style: TextStyle(color: Colors.black)),
                ),
              ),
            )
          ],
        ));
  }
}
