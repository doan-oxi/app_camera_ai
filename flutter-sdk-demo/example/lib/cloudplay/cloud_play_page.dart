import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vsdk/app_player.dart';

import 'package:get/get.dart';
import 'package:vsdk_example/cloudplay/cloud_play_state.dart';
import '../model/cloud_video_model.dart';
import '../utils/device_manager.dart';
import '../utils/manager.dart';
import '../widget/virtual_three_view.dart';
import 'cloud_play_logic.dart';

class CloudPlayerPage extends GetView<CloudPlayLogic> {
  CloudPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = controller;
    final state = logic.state;

    int splitScreen =
        Manager().getDeviceManager()?.deviceModel?.splitScreen.value ?? 0;

    double width = MediaQuery.of(context).size.width / 2 - 5;
    double height = width * 9 / 16;

    double thumWidth = 50 * 16 / 9;
    double thumHeight = 50;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('cloud Player'),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            ObxValue<RxInt>((data) {
              return data.value != 3
                  ? SinglePlayer(logic: logic, state: state)
                  : SizedBox();
            }, state!.cloudHasSubPlay),

            ///二目
            ObxValue<RxInt>((data) {
              return (data.value == 1 && splitScreen != 1)
                  ? AspectRatio(
                      aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                      child: AppPlayerView(
                        controller: state.cloudPlayer2Controller!,
                      ),
                    )
                  : SizedBox();
            }, state.cloudHasSubPlay),
            SizedBox(height: 10),

            ///三目或假三目
            ObxValue<RxInt>((data) {
              return (data.value == 1 && splitScreen == 1) //假三目
                  ? _VirtualThreeWidget(
                      height: height, state: state, width: width)
                  : data.value == 2 //真三目
                      ? _ThreeWidget(state: state)
                      : SizedBox();
            }, state.cloudHasSubPlay),

            ///四目
            ObxValue<RxInt>((data) {
              return (data.value == 3)
                  ? FourPlayer(
                      width: width,
                      height: height,
                      splitScreen: splitScreen,
                      controller: controller,
                      state: state)
                  : SizedBox();
            }, state.cloudHasSubPlay),
            SizedBox(height: 10),

            SizedBox(height: 10),
            Expanded(
                child: ObxValue<Rx<List>>((data) {
              return data.value.isEmpty
                  ? SizedBox()
                  : ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        CloudVideoGroupModel model =
                            data.value[index] as CloudVideoGroupModel;
                        return GestureDetector(
                            onTap: () {
                              logic.getUrlAndPlay(data
                                  .value[index].original.first.segmenKey.value);
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 0.5))),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    width: thumWidth,
                                    height: thumHeight,
                                    fit: BoxFit.cover,
                                    imageUrl: model.coverUrl.value,
                                    fadeInCurve: Curves.linear,
                                    fadeOutCurve: Curves.linear,
                                    placeholder: (context, url) {
                                      return Container(
                                          width: thumWidth,
                                          height: thumHeight,
                                          child: Container(
                                            width: thumWidth,
                                            height: thumHeight,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              // color: Colors.black12
                                            ),
                                            child: Image.asset(
                                                'icons/message_cell_default_image.png',
                                                fit: BoxFit.fill),
                                          ));
                                    },
                                    errorWidget: (context, url, error) {
                                      return Container(
                                          width: thumWidth,
                                          height: thumHeight,
                                          child: Container(
                                            width: thumWidth,
                                            height: thumHeight,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              // color: Colors.black12
                                            ),
                                            child: Image.asset(
                                                'icons/message_cell_default_image.png',
                                                fit: BoxFit.fill),
                                          ));
                                    },
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(data.value[index].original.first
                                      .segmenKey.value),
                                ],
                              ),
                            ));
                      },
                      itemCount: data.value.length);
            }, state.keyList))
          ],
        ),
      ),
    );
  }
}

class FourPlayer extends StatelessWidget {
  const FourPlayer({
    super.key,
    required this.width,
    required this.height,
    required this.splitScreen,
    required this.controller,
    required this.state,
  });

  final double width;
  final double height;
  final int splitScreen;
  final CloudPlayLogic controller;
  final CloudPlayState? state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("球机"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: AspectRatio(
                aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                child: splitScreen == 2
                    ? VirtualThreeView(
                        child: AppPlayerView(
                          controller: controller.state!.playerController!,
                        ),
                        alignment: Alignment.centerLeft,
                        width: width,
                        height: height,
                      )
                    : AppPlayerView(
                        controller: state!.playerController!,
                      ),
              ),
            ),
            SizedBox(
              width: width,
              height: height,
              child: AspectRatio(
                aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                child: splitScreen == 2
                    ? VirtualThreeView(
                        child: AppPlayerView(
                          controller: controller.state!.playerController!,
                        ),
                        alignment: Alignment.centerRight,
                        width: width,
                        height: height,
                      )
                    : AppPlayerView(
                        controller: state!.cloudPlayer4Controller!,
                      ),
              ),
            )
          ],
        ),
        SizedBox(height: 5),
        Text("枪机"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: AspectRatio(
                aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                child: splitScreen == 2
                    ? VirtualThreeView(
                        child: AppPlayerView(
                          controller: controller.state!.cloudPlayer2Controller!,
                        ),
                        alignment: Alignment.centerLeft,
                        width: width,
                        height: height,
                      )
                    : AppPlayerView(
                        controller: state!.cloudPlayer2Controller!,
                      ),
              ),
            ),
            SizedBox(
              width: width,
              height: height,
              child: AspectRatio(
                aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
                child: splitScreen == 2
                    ? VirtualThreeView(
                        child: AppPlayerView(
                          controller: controller.state!.cloudPlayer2Controller!,
                        ),
                        alignment: Alignment.centerRight,
                        width: width,
                        height: height,
                      )
                    : AppPlayerView(
                        controller: state!.cloudPlayer3Controller!,
                      ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class SinglePlayer extends StatelessWidget {
  const SinglePlayer({
    super.key,
    required this.logic,
    required this.state,
  });

  final CloudPlayLogic logic;
  final CloudPlayState? state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.width * 9 / 16,
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
              child: AppPlayerView(
                controller: logic.controller,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                ObxValue<Rx<VideoStatus>>((data) {
                  return IconButton(
                    icon: data.value == VideoStatus.PLAY
                        ? Icon(Icons.stop)
                        : Icon(Icons.play_arrow),
                    color: Colors.white,
                    onPressed: () async {
                      print("---------onPressed----------");
                      if (data.value == VideoStatus.PLAY) {
                        ///暂停播放
                        logic.stopVideo();
                      } else {
                        ///开始播放
                        logic.startVideo();
                      }
                    },
                  );
                }, state!.videoStatus)
              ],
            ),
          ),
          ObxValue<Rx<VideoStatus>>((data) {
            return data.value == VideoStatus.STARTING
                ? Center(
                    child: SpinKitWave(
                      color: Colors.white,
                      size: 32,
                    ),
                  )
                : SizedBox();
          }, state!.videoStatus),
        ],
      ),
    );
  }
}

class _ThreeWidget extends StatelessWidget {
  const _ThreeWidget({
    super.key,
    required this.state,
  });

  final CloudPlayState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
          child: AppPlayerView(
            controller: state.cloudPlayer2Controller!, //假三目
          ),
        ),
        SizedBox(width: 10),
        AspectRatio(
          aspectRatio: 16 / 9, //横纵比 长宽比 16 : 9
          child: AppPlayerView(
            controller: state.cloudPlayer3Controller!, //假三目
          ),
        ),
      ],
    );
  }
}

class _VirtualThreeWidget extends StatelessWidget {
  const _VirtualThreeWidget({
    super.key,
    required this.height,
    required this.state,
    required this.width,
  });

  final double height;
  final CloudPlayState state;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      child: Row(
        children: [
          VirtualThreeView(
            child: AppPlayerView(
              controller: state.cloudPlayer2Controller!, //假三目
            ),
            alignment: Alignment.centerLeft,
            width: width,
            height: height,
          ),
          SizedBox(width: 10),
          VirtualThreeView(
            child: AppPlayerView(
              controller: state.cloudPlayer2Controller!, //假三目
            ),
            alignment: Alignment.centerRight,
            width: width,
            height: height,
          ),
        ],
      ),
    );
  }
}
