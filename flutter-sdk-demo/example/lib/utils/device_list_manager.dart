import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../home/home_logic.dart';

class DeviceListManager {
  /// 单例
  static DeviceListManager? _instance;

  /// 将构造函数指向单例
  factory DeviceListManager() => getInstance();

  ///获取单例
  static DeviceListManager getInstance() {
    if (_instance == null) {
      _instance = new DeviceListManager._internal();
    }
    return _instance!;
  }

  DeviceListManager._internal();

  Future<String?> getDevicePsw(String did) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('$did');
  }

  Future<bool> setDevicePsw(String did, String psw) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString('$did', psw);
  }

  // 存储设备列表数据
  Future<void> saveDeviceArray(List<String> array) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 将数组转换为JSON字符串
    String jsonString = jsonEncode(array);
    // 存储字符串
    await prefs.setString('device_list', jsonString);
  }

// 获取设备列表数据
  Future<List<String>> getDeviceArray() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 获取存储的字符串
    String jsonString = prefs.getString('device_list') ?? '[]';
    // 将JSON字符串转换回数组
    List<String> array = List<String>.from(jsonDecode(jsonString));
    return array;
  }

  Future<void> saveDevice(String uid, String psw) async {
    List<String> devices = await getDeviceArray();
    devices.add(uid);
    await saveDeviceArray(devices);
    await setDevicePsw(uid, psw);
    HomeLogic homeLogic = Get.find<HomeLogic>();
    homeLogic.state!.deviceList.value = devices;
  }
}
