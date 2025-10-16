import 'package:get/get.dart';

class DeviceConnectedState {
  var isShowQR = false.obs;
  Rx<String> wifiName = "".obs;
  var times = 0.obs;
  String wifiBssid = "";
  String wifiPsw = "";
  String qrContent = "";
}
