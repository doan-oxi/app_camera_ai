import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/settings_main/video/video_logic.dart';

class VideoWidget<S> extends GetView<VideoLogic> {
  VideoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = controller;
    final state = controller.state;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Color normalC = Colors.grey.withOpacity(0.8);
    Color selectC = Colors.blue.withOpacity(0.8);

    bool isDarkMode = theme.brightness == Brightness.dark;

    return Obx(() {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: logic.turnOnOffVideoCall,
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: state!.isVideoCall.value
                            ? Color.fromARGB(255, 243, 40, 67)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset.zero,
                              color: Colors.grey,
                              blurRadius: 5,
                              spreadRadius: 0.1),
                        ]),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    child: logic.cameraStart.value
                        ? Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              state.isVideoCall.value
                                  ? Icons.close
                                  : Icons.video_call,
                              size: 30,
                              color: state.isVideoCall.value
                                  ? Colors.white
                                  : normalC,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              state.isVideoCall.value ? '挂断'.tr : '视频通话'.tr,
              style: TextStyle(fontSize: 12, color: normalC),
              textScaleFactor: 1.0,
            ),
          ],
        ),
      );
    });
  }
}
