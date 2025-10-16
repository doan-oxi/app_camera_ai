import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'device_connect_logic.dart';

class DeviceConnectPage extends GetView<DeviceConnectLogic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('二维码连接'),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ObxValue<RxBool>((data) {
          return data.value
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(height: 100),
                      QrImageView(
                        data: controller.state!.qrContent,
                        size: 300.0,
                      ),
                      SizedBox(height: 20),
                      Text("请扫描二维码，设备查询成功后自动跳转下一步",
                          style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      ObxValue<RxInt>((data) {
                        return Text("设备查询中，${data.value} 次",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500));
                      }, controller.state!.times)
                    ],
                  ),
                )
              : ObxValue<Rx<String>>((data) {
                  return data.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 50),
                              Text("Wifi名称：${data.value}"),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Wifi密码："),
                                  SizedBox(
                                    width: 250,
                                    height: 38,
                                    child: TextField(
                                      controller: controller.textController,
                                      decoration: InputDecoration(
                                        labelText: '请输入密码',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              TextButton(
                                  onPressed: () {
                                    controller.generateQrCode();
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        color: Colors.blue),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "生成二维码",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )),
                            ],
                          ),
                        )
                      : Container(
                          height: 200,
                          alignment: Alignment.center,
                          child:
                              Text("未检测到wifi, 请确保手机连接WI-FI \n (app需打开位置权限)"));
                }, controller.state!.wifiName);
        }, controller.state!.isShowQR),
      ),
    );
  }
}
