import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsdk_example/settings_normal/settings_normal_logic.dart';
import 'package:vsdk_example/utils/device_list_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../app_routes.dart';
import '../home/home_logic.dart';
import '../model/device_model.dart';
import '../utils/manager.dart';

class SettingsNormalPage extends GetView<SettingsNormalLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Normal Settings'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ///低功耗模式，长电不支持
            lowPowerMode(),

            ///指示灯隐藏开关
            ledLightHideSwitch(),

            ///设备音量：麦克风/喇叭
            voiceSetting(),

            ///双目，联动开关
            linkableSwitch(),

            ///双目，联动校正
            linkableRevise(),

            ///TF录像设置
            tFSettings(),

            ///视频管理
            videoManager(),

            ///自动熄屏时间
            if (Manager()
                    .getDeviceManager()
                    ?.deviceModel
                    ?.isSupportVideoCall
                    .value ==
                true)
              screenTimeWidget(),

            ///屏幕亮度调节
            if (Manager()
                    .getDeviceManager()
                    ?.deviceModel
                    ?.isSupportVideoCall
                    .value ==
                true)
              screenBrightnessWidget(),

            SizedBox(height: 50),
            InkWell(
                onTap: () async {
                  List<String> devices =
                      await DeviceListManager.getInstance().getDeviceArray();
                  devices.remove(Manager().getCurrentUid());
                  DeviceListManager.getInstance().saveDeviceArray(devices);
                  HomeLogic homeLogic = Get.find<HomeLogic>();
                  homeLogic.state!.deviceList.value = devices;
                  Get.until((route) => route.settings.name == AppRoutes.home);
                  EasyLoading.showSuccess("删除成功");
                },
                child: Text("删除设备",
                    style: TextStyle(color: Colors.red, fontSize: 16))),
          ],
        ),
      ),
    ));
  }

  ///音量设置
  Widget voiceSetting() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          controller.onVoiceClick();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("设备音量：", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("麦克风/喇叭 >>")
          ],
        ),
      ),
    );
  }

  Widget ledLightHideSwitch() {
    return Visibility(
        visible:
            Manager().getDeviceManager()!.deviceModel!.isSupportledLight.value,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide()),
          ),
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("指示灯隐藏：", style: TextStyle(fontWeight: FontWeight.bold)),
              ObxValue<RxBool>((data) {
                return Switch(
                    value: data.value,
                    onChanged: (value) {
                      print("----------指示灯隐藏-------Switch--$value--");
                      controller.ledLightHidden(value);
                    });
              }, controller.state!.ledHidden)
            ],
          ),
        ));
  }

  Widget lowPowerMode() {
    return Visibility(
        visible:
            Manager().getDeviceManager()!.deviceModel!.isSupportLowPower.value,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide()),
          ),
          height: 50,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              showLowPowerModeSettingSheet();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("功耗模式：", style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() {
                  String name = "";
                  if (controller.state!.smartElecSwitch.value) {
                    name = "微功耗模式";
                  } else {
                    switch (controller.state!.lowMode.value) {
                      case LowMode.low:
                        name = "省电模式";
                        break;
                      case LowMode.none:
                        name = "持续工作模式";
                        break;
                      case LowMode.veryLow:
                        name = "超级省电模式";
                        break;
                      case LowMode.smart:
                        name = "微功耗模式";
                        break;
                      case null:
                        break;
                    }
                  }
                  return Text("$name >>",
                      style: TextStyle(fontWeight: FontWeight.normal));
                })
              ],
            ),
          ),
        ));
  }

  void showLowPowerModeSettingSheet() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            decoration: BoxDecoration(border: Border(top: BorderSide())),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Manager()
                          .getDeviceManager()!
                          .deviceModel!
                          .supportNewLowPower
                          .value ==
                      -1
                  ? oldLowModes()
                  : newLowModes(),
            ),
          );
        });
  }

  Widget oldLowModes() {
    return Column(
      children: [
        GestureDetector(
            onTap: () {
              ///设置为省电模式
              controller.onClickSavePowerMode();
            },
            child: Text("省电模式", style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(height: 12),
        Visibility(
            visible: Manager()
                    .getDeviceManager()!
                    .getDeviceModel()!
                    .supportSmartElectricitySleep
                    .value ==
                1,
            child: GestureDetector(
                onTap: () {
                  ///设置为智能省电模式(微功耗模式)
                  bool switchValue = Manager()
                          .getDeviceManager()!
                          .deviceModel
                          ?.smartElectricitySleepSwitch
                          .value ??
                      false;
                  controller.setSmartElectricitySleep(switchValue ? 0 : 1, 30);
                },
                child: Text("微功耗模式",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Visibility(
            visible: Manager()
                        .getDeviceManager()!
                        .getDeviceModel()!
                        .supportLowPower
                        .value !=
                    7 &&
                Manager()
                        .getDeviceManager()!
                        .getDeviceModel()!
                        .supportLowPower
                        .value !=
                    8,
            child: GestureDetector(
                onTap: () {
                  controller.onClickKeepWorkMode();
                },
                child: Text("持续工作模式",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Visibility(
            visible: Manager()
                .getDeviceManager()!
                .getDeviceModel()!
                .isSupportDeepLowPower
                .value,
            child: GestureDetector(
                onTap: () {
                  controller.onClickVeryLowPowerMode();
                },
                child: Text("超级省电模式",
                    style: TextStyle(fontWeight: FontWeight.bold))))
      ],
    );
  }

  Widget newLowModes() {
    var value = Manager()
        .getDeviceManager()!
        .getDeviceModel()!
        .supportNewLowPower
        .value;

    var isSupportLow = value & 0x1 > 0;
    var isSupportAlways = value & 0x2 > 0;
    var isSupportDeep = value & 0x4 > 0;
    var isSupportMicro = value & 0x8 > 0;
    return Column(
      children: [
        Visibility(
            visible: isSupportLow,
            child: GestureDetector(
                onTap: () {
                  ///设置为省电模式
                  controller.onClickSavePowerMode();
                },
                child: Text("省电模式",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Visibility(
            visible: isSupportMicro,
            child: GestureDetector(
                onTap: () {
                  ///设置为智能省电模式(微功耗模式)
                  bool switchValue = Manager()
                          .getDeviceManager()!
                          .deviceModel
                          ?.smartElectricitySleepSwitch
                          .value ??
                      false;
                  controller.setSmartElectricitySleep(switchValue ? 0 : 1, 30);
                },
                child: Text("微功耗模式",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Visibility(
            visible: isSupportAlways,
            child: GestureDetector(
                onTap: () {
                  controller.onClickKeepWorkMode();
                },
                child: Text("持续工作模式",
                    style: TextStyle(fontWeight: FontWeight.bold)))),
        SizedBox(height: 12),
        Visibility(
            visible: isSupportDeep,
            child: GestureDetector(
                onTap: () {
                  controller.onClickVeryLowPowerMode();
                },
                child: Text("超级省电模式",
                    style: TextStyle(fontWeight: FontWeight.bold))))
      ],
    );
  }

  ///联动开关
  Widget linkableSwitch() {
    return Visibility(
        visible:
            Manager().getDeviceManager()!.deviceModel!.supportPinInPic.value ==
                    1 ||
                Manager()
                        .getDeviceManager()!
                        .deviceModel!
                        .supportMutilSensorStream
                        .value ==
                    1,
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide()),
          ),
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("联动开关：", style: TextStyle(fontWeight: FontWeight.bold)),
              ObxValue<RxBool>((data) {
                return Switch(
                    value: data.value,
                    onChanged: (value) {
                      print("----------联动开关-------Switch--$value--");
                      controller.controlLinkableEnable(value);
                    });
              }, controller.state!.linkableSwitch)
            ],
          ),
        ));
  }

  ///联动校正
  Widget linkableRevise() {
    return ObxValue<RxBool>((data) {
      return data.value
          ? Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide()),
              ),
              height: 50,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.linkable);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("联动校正：",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(" >>")
                  ],
                ),
              ),
            )
          : SizedBox();
    }, controller.state!.linkableSwitch);
  }

  ///TF卡录像设置
  Widget tFSettings() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.tfSettings);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("TF录像设置：", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(" >>")
          ],
        ),
      ),
    );
  }

  ///视频管理
  Widget videoManager() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          showVideoManagerSheet();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("视频管理：", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(" >>")
          ],
        ),
      ),
    );
  }

  void showVideoManagerSheet() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Container(
            height: 350,
            decoration: BoxDecoration(border: Border(top: BorderSide())),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text("视频画面翻转：",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: () {
                            controller.setCameraDirection(false);
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("不翻转",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.black
                                        : Colors.blue));
                          }, controller.state!.isOverturn)),
                      InkWell(
                          onTap: () {
                            controller.setCameraDirection(true);
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("上下翻转",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.blue
                                        : Colors.black));
                          }, controller.state!.isOverturn)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Divider(height: 1),
                  SizedBox(height: 15),
                  Text("灯光抗干扰：", style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: () {
                            controller.setLightMode(true);
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("60HZ",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.blue
                                        : Colors.black));
                          }, controller.state!.is60Hz)),
                      InkWell(
                          onTap: () {
                            controller.setLightMode(false);
                          },
                          child: ObxValue<RxBool>((data) {
                            return Text("50HZ",
                                style: TextStyle(
                                    color: data.value
                                        ? Colors.black
                                        : Colors.blue));
                          }, controller.state!.is60Hz)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Divider(height: 1),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "时间显示:",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      ObxValue<RxBool>((data) {
                        return Switch(
                            value: data.value,
                            onChanged: (data) {
                              controller.setVideoTimeOsd(data);
                            });
                      }, controller.state!.isTimeOSD)
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  ///自动熄屏时间
  Widget screenTimeWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          showScreenTimeSheet();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("自动熄屏时间：", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(" >>")
          ],
        ),
      ),
    );
  }

  void showScreenTimeSheet() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Container(
            height: 450,
            decoration: BoxDecoration(border: Border(top: BorderSide())),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  timeCellWidget("30s", 0),
                  timeCellWidget("1min", 1),
                  timeCellWidget("2min", 2),
                  timeCellWidget("3min", 3),
                  timeCellWidget("4min", 4),
                  timeCellWidget("5min", 5),
                  timeCellWidget("永不熄屏", 6),
                  timeCellWidget("暗黑模式", 7),
                ],
              ),
            ),
          );
        });
  }

  Widget timeCellWidget(String text, int index) {
    return InkWell(
      onTap: () {
        controller.setScreenTime(index);
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide()),
        ),
        child: ObxValue<RxInt>((data) {
          return Text(
            text,
            style: TextStyle(
                color: data.value == index ? Colors.blue : Colors.black),
          );
        }, controller.state!.screenTimeIndex),
      ),
    );
  }

  ///屏幕亮度调节
  Widget screenBrightnessWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          showBrightnessSheet();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("设备屏幕亮度调节：", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(" >>")
          ],
        ),
      ),
    );
  }

  void showBrightnessSheet() {
    showModalBottomSheet(
        context: Get.context!,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            decoration: BoxDecoration(border: Border(top: BorderSide())),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            controller.cancelSet();
                          },
                          child: Text(
                            "取消",
                            style: TextStyle(color: Colors.grey),
                          )),
                      Text("设备屏幕亮度调节", style: TextStyle(color: Colors.black)),
                      InkWell(
                          onTap: () {
                            controller.setBrightness();
                          },
                          child:
                              Text("确定", style: TextStyle(color: Colors.blue))),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Text("暗", style: TextStyle(color: Colors.black)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                              activeTrackColor: Colors.blue,
                              inactiveTrackColor: Colors.grey,
                              thumbColor: Colors.white,
                              trackHeight: 8.0),
                          child: ObxValue<RxInt>((data) {
                            return Slider(
                              value: data.value.toDouble(),
                              onChanged: (data) {
                                print("-----data-------$data-----");
                                controller.state!.currentBrightnessValue.value =
                                    data.toInt();
                              },
                              onChangeStart: (data) {},
                              onChangeEnd: (data) {},
                              min: 0.0,
                              max: 100.0,
                              divisions: 100,
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.round()}';
                              },
                            );
                          }, controller.state!.currentBrightnessValue),
                        ),
                      ),
                      Text("亮", style: TextStyle(color: Colors.black)),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
