import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/app_routes.dart';
import '../play/play_conf.dart';
import '../utils/manager.dart';
import 'home_logic.dart';

class HomePage extends GetView<HomeLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('设备'),
          actions: [
            IconButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.main);
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: ObxValue<Rx<List<String>>>((data) {
          return data.value.length == 0
              ? NoDeviceWidget()
              : CustomScrollView(slivers: [
                  // SliverAppBar(
                  //   title: Text("设备列表"),
                  //   floating: true,
                  //   snap: true,
                  //   actions: [
                  //     IconButton(
                  //         onPressed: () {
                  //           Get.toNamed(AppRoutes.main);
                  //         },
                  //         icon: Icon(Icons.add))
                  //   ],
                  // ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                    return Container(
                      height: 200,
                      margin: EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)), // 边色与边宽度
                        image: DecorationImage(
                          image: AssetImage("icons/home_device.png"),
                          fit: BoxFit.fill,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10, //阴影范围
                            spreadRadius: 0.1, //阴影浓度
                            color: Colors.grey.withOpacity(0.2), //阴影颜色
                          ),
                        ],
                      ),
                      child: ObxValue<RxInt>((refresh) {
                        String status = controller.getStatus(data.value[index]);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 150,
                              child: Stack(
                                children: [
                                  Visibility(
                                    visible: refresh.value != -1,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          status == "off" ? "" : status,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: status == "off"
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.warning_rounded,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "设备离线",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          )
                                        : status == ""
                                            ? InkWell(
                                                onTap: () async {
                                                  String psw = await controller
                                                      .setDataBeforeToPlay(
                                                          data.value[index]);
                                                  Get.toNamed(AppRoutes.play,
                                                      arguments: PlayArgs(
                                                          data.value[index],
                                                          psw));
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.warning_rounded,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "连接失败",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: () async {
                                                  String psw = await controller
                                                      .setDataBeforeToPlay(
                                                          data.value[index]);
                                                  Get.toNamed(AppRoutes.play,
                                                      arguments: PlayArgs(
                                                          data.value[index],
                                                          psw));
                                                },
                                                icon: Icon(
                                                  Icons.play_circle,
                                                  size: 50,
                                                  color: Colors.white,
                                                )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(data.value[index],
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400)),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        Manager()
                                            .setCurrentUid(data.value[index]);
                                        Get.toNamed(AppRoutes.cloudplay);
                                      },
                                      icon: Icon(
                                        Icons.cloud,
                                        color: Colors.yellow,
                                      )),
                                  // SizedBox(width: 10),
                                  IconButton(
                                      onPressed: () {
                                        Manager()
                                            .setCurrentUid(data.value[index]);
                                        Get.toNamed(AppRoutes.tfPlay);
                                      },
                                      icon: Icon(
                                        Icons.sd_card_outlined,
                                        color: Colors.black,
                                      )),
                                  // SizedBox(width: 10),
                                  IconButton(
                                      onPressed: () {
                                        Manager()
                                            .setCurrentUid(data.value[index]);
                                        Get.toNamed(AppRoutes.normalSetting);
                                      },
                                      icon: Icon(
                                        Icons.settings,
                                        color: Colors.black,
                                      )),
                                  SizedBox(width: 10)
                                ],
                              ),
                            )
                          ],
                        );
                      }, controller.state!.statusRefresh),
                    );
                  }, childCount: data.value.length)),
                ]);
        }, controller.state!.deviceList),
      ),
    );
  }
}

class NoDeviceWidget extends StatelessWidget {
  const NoDeviceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 100),
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.main);
            },
            child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue,
                ),
                alignment: Alignment.center,
                child: Text("+",
                    style: TextStyle(fontSize: 30, color: Colors.white))),
          ),
          SizedBox(height: 10),
          Text("暂无设备"),
          Text("请点击添加设备"),
        ],
      ),
    );
  }
}
