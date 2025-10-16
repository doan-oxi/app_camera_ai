import 'package:vsdk/camera_device/commands/status_command.dart';
import 'package:vsdk_example/utils/device_list_manager.dart';
import '../model/device_model.dart';
import '../utils/device.dart';
import '../utils/manager.dart';
import '../utils/super_put_controller.dart';
import 'home_state.dart';

class HomeLogic extends SuperPutController<HomeState> {
  HomeLogic() {
    value = HomeState();
  }

  @override
  void onInit() {
    getDeviceList();
    super.onInit();
  }

  getDeviceList() async {
    List<String> deviceList =
        await DeviceListManager.getInstance().getDeviceArray();
    state!.deviceList.value = deviceList;
    getAllDeviceStatus(deviceList);
  }

  getAllDeviceStatus(List<String> deviceList) {
    deviceList.forEach((element) async {
      if (element.isNotEmpty) {
        await setDataBeforeToPlay(element);
        await Device()
            .connectDevice(Manager().getDeviceManager(id: element)!.mDevice!);
        StatusResult? result = await Manager()
            .getDeviceManager(id: element)
            ?.mDevice
            ?.getStatus(cache: false);
        if (result != null) {
          print("------getAllDeviceStatus-$element---${result.p2pstatus}---");
        }
      }
    });
  }

  Future<String> setDataBeforeToPlay(String uid) async {
    int sensor = await Manager().getDeviceManager(id: uid)!.getSensorValue(uid);
    int splitScreen =
        await Manager().getDeviceManager(id: uid)!.getSplitValue(uid);
    String psw =
        await DeviceListManager.getInstance().getDevicePsw(uid) ?? "888888";
    Device().buildDevice(uid, "test", psw);
    Manager()
        .getDeviceManager(id: uid)
        ?.deviceModel
        ?.supportMutilSensorStream
        .value = sensor;
    Manager().getDeviceManager(id: uid)?.deviceModel?.splitScreen.value =
        splitScreen;
    return psw;
  }

  String getStatus(String uid) {
    String status = "连接中...";
    DeviceModel model = Manager().getDeviceManager(id: uid)!.deviceModel!;
    print(
        "--getStatus--$uid--${model.onLineStatus.value}--${model.connectState.value}--${model.p2pStatus.value}--");
    if (model.p2pStatus.value == 1) return "在线";

    switch (model.onLineStatus.value) {
      case DeviceOnLineState.offline:
        if (model.connectState.value == DeviceConnectState.offline ||
            model.connectState.value == DeviceConnectState.timeout) {
          status = "off";
        }
        break;
      case DeviceOnLineState.online:
        status = "在线";
        break;
      case DeviceOnLineState.sleep:
        status = "睡眠模式";
        break;
      case DeviceOnLineState.deepSleep:
        status = "睡眠模式";
        break;
      case DeviceOnLineState.poweroff:
        status = "已关机";
        break;
      case DeviceOnLineState.lowPowerOff:
        status = "已关机";
        break;
      case DeviceOnLineState.microPower:
        status = "微功耗模式";
        break;
      case DeviceOnLineState.none:
        break;
    }
    if (status != "连接中...") return status;

    switch (model.connectState.value) {
      case DeviceConnectState.connecting:
        break;
      case DeviceConnectState.logging:
        break;
      case DeviceConnectState.connected:
        status = "在线";
        break;
      case DeviceConnectState.offline:
        status = "off";
        break;
      case DeviceConnectState.none:
        status = "";
        break;
      case DeviceConnectState.timeout:
        status = "";
        break;
      case DeviceConnectState.disconnect:
        status = "";
        break;
      case DeviceConnectState.password:
        status = "";
        break;
      case DeviceConnectState.maxUser:
        status = "";
        break;
      case DeviceConnectState.illegal:
        status = "";
        break;
    }

    return status;
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
