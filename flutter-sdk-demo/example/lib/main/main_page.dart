import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_routes.dart';
import '../utils/device.dart';
import '../utils/device_list_manager.dart';
import '../utils/manager.dart';
import 'main_logic.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MainPage extends GetView<MainLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add Device'),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 100),
              Row(
                children: [
                  Text("设备id:"),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 250,
                    height: 38,
                    child: ObxValue<RxBool>((data) {
                      return TextField(
                        controller: controller.idController,
                        decoration: InputDecoration(
                          labelText: '请输入uid',
                          hintText: data.isTrue ? controller.state!.uid : null,
                          border: OutlineInputBorder(),
                        ),
                      );
                    }, controller.state!.isGetDevice),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text("   密码:"),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 250,
                    height: 38,
                    child: TextField(
                      controller: controller.pswController,
                      decoration: InputDecoration(
                        labelText: '888888',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              TextButton(
                  onPressed: () async {
                    controller.saveDeviceInfo();
                    if (controller.state!.uid == null ||
                        controller.state!.uid!.isEmpty) {
                      EasyLoading.showToast("设备id不能为空！");
                      return;
                    }
                    EasyLoading.show();
                    bool bl = await Device().init(controller.state!.uid!,
                        psw: controller.state!.psw);
                    EasyLoading.dismiss();
                    if (bl) {
                      Manager().setCurrentUid(controller.state!.uid!);
                      await DeviceListManager.getInstance().saveDevice(
                          controller.state!.uid!, controller.state!.psw);
                      Get.offAndToNamed(AppRoutes.play);
                    } else {
                      Device().showTips(controller.state!.uid!);
                    }
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width - 48,
                      height: 48,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.blue),
                      alignment: Alignment.center,
                      child:
                          Text("点击连接", style: TextStyle(color: Colors.white)))),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: () {
                        controller.state!.isGetDevice.value = false;
                        Get.offAndToNamed(AppRoutes.deviceConnect);
                        //     ?.then((data) async {
                        //   print("----qrDevice-id-$data---------");
                        //   saveUid(data);
                        // });
                      },
                      child: Text("二维码配网连接",
                          style: TextStyle(color: Colors.blue))),
                  InkWell(
                      onTap: () {
                        controller.state!.isGetDevice.value = false;
                        Get.offAndToNamed(AppRoutes.bluetoothConnect);
                        //     ?.then((data) {
                        //   saveUid(data);
                        // });
                      },
                      child:
                          Text("蓝牙配网连接", style: TextStyle(color: Colors.blue))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveUid(data) {
    controller.state!.isGetDevice.value = true;
    if (data is String && data.isNotEmpty) {
      controller.state!.uid = data;
      controller.idController.text = data;
      EasyLoading.showToast("设备获取成功，请点击连接");
    }
  }

// Future<void> goToPlayPage(MainState? state) async {
//   print("state?.connectState ${state?.connectState}");
//   if (state?.connectState == CameraConnectState.connected) {
//     Get.toNamed(AppRoutes.play);
//   } else if (state?.connectState == CameraConnectState.password) {
//     ///
//     EasyLoading.showToast("密码错误，请使用正确的密码");
//   } else if (state?.connectState == CameraConnectState.none) {
//     ///初始化失败
//   } else if (state?.connectState == CameraConnectState.offline) {
//     ///初始化失败
//     EasyLoading.showToast("设备已离线，请唤醒设备重试");
//   } else if (state?.connectState == CameraConnectState.disconnect ||
//       state?.connectState == CameraConnectState.timeout) {
//     ///重新连接
//     EasyLoading.showToast("设备连接断开，正在重新连接，请稍等");
//     bool bl =
//         await controller.connectDevice(DeviceManager.getInstance().mDevice!);
//     if (bl) {
//       Get.toNamed(AppRoutes.play);
//     } else {
//       EasyLoading.showToast("连接失败，请重试！");
//     }
//   }
// }
}
