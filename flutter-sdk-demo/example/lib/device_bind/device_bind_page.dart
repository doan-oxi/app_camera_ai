import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_routes.dart';
import '../main/main_logic.dart';
import '../utils/device.dart';
import '../utils/device_list_manager.dart';
import '../utils/manager.dart';
import 'device_bind_logic.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DeviceBindPage extends GetView<DeviceBindLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('设备绑定'),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("确认绑定摄像机 ${controller.uid}"),
              SizedBox(height: 50),
              Row(
                children: [Text("摄像机名称"), Spacer()],
              ),
              SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 48,
                  height: 48,
                  child: ObxValue<Rx<String>>((data) {
                    return TextField(
                      controller: controller.textController,
                      decoration: InputDecoration(
                        labelText: 'WIFI摄像机',
                        hintText: data.value,
                        border: OutlineInputBorder(),
                      ),
                    );
                  }, controller.state!.deviceName)),
              SizedBox(height: 20),
              Wrap(
                spacing: 30,
                runSpacing: 10,
                children: [
                  nameWidget("车库"),
                  nameWidget("前门"),
                  nameWidget("院子"),
                  nameWidget("客厅"),
                  nameWidget("办公室"),
                  nameWidget("后花园"),
                  nameWidget("过道"),
                  nameWidget("门口"),
                  nameWidget("阳台"),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  if (controller.textController.text.length == 0) {
                    EasyLoading.showToast("你还未输入相机名称!");
                    return;
                  }
                  EasyLoading.show();
                  bool bl = await Device().init(controller.uid!,
                      name: controller.textController.text);
                  EasyLoading.dismiss();
                  if (bl) {
                    Manager().setCurrentUid(controller.uid!);
                    await DeviceListManager.getInstance()
                        .saveDevice(controller.uid!, "888888");
                    Get.offAndToNamed(AppRoutes.play);
                  } else {
                    Device().showTips(controller.uid!);
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 48,
                  height: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.blue),
                  alignment: Alignment.center,
                  child: Text("点击连接", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nameWidget(String name) {
    return InkWell(
      onTap: () {
        controller.textController.text = name;
        controller.state!.deviceName.value = name;
      },
      child: Container(
        width: 80,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: Text(name),
      ),
    );
  }
}
