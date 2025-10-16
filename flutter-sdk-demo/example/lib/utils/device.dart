import 'package:vsdk/camera_device/camera_device.dart';
import 'package:vsdk/camera_device/commands/status_command.dart';
import 'package:vsdk/camera_device/commands/wakeup_command.dart';
import 'package:vsdk/device_wakeup_server.dart';
import 'package:vsdk/p2p_device/p2p_device.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../home/home_logic.dart';
import '../model/device_model.dart';
import 'manager.dart';
import 'package:get/get.dart';

class Device {
  Future<bool> init(String did,
      {String psw = "888888", String name = "办公室"}) async {
    ///did 你的摄像机did
    CameraDevice device = buildDevice(did, name, psw);
    bool bl = await connectDevice(device);
    return bl;
  }

  CameraDevice buildDevice(String did, String name, String psw) {
    CameraDevice device = CameraDevice(did, name, 'admin', psw, 'QW6-T');
    Manager().getDeviceManager(id: did)!.setDevice(device);
    device.getClientPtr();
    DeviceModel deviceModel = DeviceModel(device.id, device);
    Manager().getDeviceManager(id: did)!.setDeviceModel(deviceModel);
    return device;
  }

  Future<bool> connectDevice(CameraDevice device) async {
    device.removeListener(statusListener);
    device.removeListener(_connectStateListener);
    device.removeListener(_wakeupStateListener);
    device.addListener<StatusChanged>(statusListener);
    device.addListener<CameraConnectChanged>(_connectStateListener);
    device.addListener<WakeupStateChanged>(_wakeupStateListener);
    CameraConnectState connectState = await device.connect();
    _connectStateListener(device, connectState);
    _wakeupStateListener(device, device.wakeupState);
    device.requestWakeupStatus();
    print("设备状态：connectState $connectState");
    if (connectState == CameraConnectState.connected) {
      var result = await device.getParams(cache: false);
      print("result $result");
      return true;
    }
    return false;
  }

  void _wakeupStateListener(
      P2PBasisDevice device, DeviceWakeupState? wakeupState) async {
    var deviceModel = Manager().getDeviceManager(id: device.id)!.deviceModel;
    if (deviceModel == null) return;
    if (wakeupState == null) return;
    if (wakeupState != DeviceWakeupState.poweroff) {
      deviceModel.isRemoteControlLoading.value = false;
    }
    print("----------wakeupState-----$wakeupState");
    switch (wakeupState) {
      case DeviceWakeupState.offline:
        deviceModel.onLineStatus.value = DeviceOnLineState.offline;
        break;
      case DeviceWakeupState.deepSleep:
        deviceModel.onLineStatus.value = DeviceOnLineState.deepSleep;
        break;
      case DeviceWakeupState.sleep:
        deviceModel.onLineStatus.value = DeviceOnLineState.sleep;
        break;
      case DeviceWakeupState.online:
        deviceModel.onLineStatus.value = DeviceOnLineState.online;
        break;
      case DeviceWakeupState.poweroff:
        deviceModel.remoteCloseCount.value = 0;
        deviceModel.onLineStatus.value = DeviceOnLineState.poweroff;
        break;
      case DeviceWakeupState.microPower:
        deviceModel.onLineStatus.value = DeviceOnLineState.microPower;
        break;
      case DeviceWakeupState.lowPowerOff:
        deviceModel.onLineStatus.value = DeviceOnLineState.lowPowerOff;
        break;
    }
    HomeLogic homeLogic = Get.find<HomeLogic>();
    homeLogic.state!.statusRefresh.value++;
  }

  void _connectStateListener(
      CameraDevice device, CameraConnectState connectState) {
    var deviceModel = Manager().getDeviceManager(id: device.id)!.deviceModel;
    if (deviceModel == null) return;
    print("------connectState------$connectState---------------");
    // state!.connectState = connectState;
    switch (connectState) {
      case CameraConnectState.connecting:
        deviceModel.connectState.value = DeviceConnectState.connecting;
        break;
      case CameraConnectState.logging:
        deviceModel.connectState.value = DeviceConnectState.logging;
        break;
      case CameraConnectState.connected:
        deviceModel.connectState.value = DeviceConnectState.connected;
        break;
      case CameraConnectState.timeout:
        deviceModel.connectState.value = DeviceConnectState.timeout;
        break;
      case CameraConnectState.disconnect:
        deviceModel.connectState.value = DeviceConnectState.disconnect;
        break;
      case CameraConnectState.password:
        deviceModel.connectState.value = DeviceConnectState.password;
        break;
      case CameraConnectState.maxUser:
        deviceModel.connectState.value = DeviceConnectState.maxUser;
        break;
      case CameraConnectState.offline:
        deviceModel.connectState.value = DeviceConnectState.offline;
        HomeLogic homeLogic = Get.find<HomeLogic>();
        homeLogic.state!.statusRefresh.value++;
        break;
      case CameraConnectState.illegal:
        deviceModel.connectState.value = DeviceConnectState.illegal;
        break;
      case CameraConnectState.none:
        deviceModel.connectState.value = DeviceConnectState.none;
        break;
    }
  }

  void statusListener(P2PBasisDevice device, StatusResult? result) {
    if (result == null) return;
    print("device status changed -----:"
        "--低功耗（可充电后待机使用）-isSupportLowPower--${result.support_low_power}--"
        "result.batteryRate--${result.batteryRate}");

    DeviceModel? deviceModel =
        Manager().getDeviceManager(id: device.id)!.deviceModel;
    if (deviceModel == null) return;

    if (result.p2pstatus != null) {
      deviceModel.p2pStatus.value = int.tryParse(result.p2pstatus ?? "0") ?? 0;
      HomeLogic homeLogic = Get.find<HomeLogic>();
      homeLogic.state!.statusRefresh.value++;
    }

    if (result.batteryRate != null) {
      deviceModel.batteryRate.value =
          int.tryParse(result.batteryRate ?? "0") ?? 0;
    }

    if (result.support_humanDetect != null) {
      deviceModel.supportHumanDetect.value =
          int.tryParse(result.support_humanDetect ?? "0") ?? 0;
    }

    if (result.hardwareTestFunc != null) {
      Manager()
          .getDeviceManager(id: device.id)!
          .setHardwareTestFunc(device.id, result.hardwareTestFunc!);
      int supportMode = int.tryParse(result.hardwareTestFunc ?? "") ?? 0;
      if (supportMode & 0x02 != 0) {
        deviceModel.alarmType.value = 0;
        print("----alarmType  0----支持人形侦测（低功耗）------");
      } else {
        deviceModel.alarmType.value = 1;
        print("----alarmType  1----支持移动侦测（长电）------");
      }

      ///是否支持白光灯
      if (supportMode & 0x4 != 0) {
        deviceModel.haveWhiteLight.value = true;
      }

      ///是否支持红蓝灯单独开关
      if (supportMode & 0x200 != 0) {
        deviceModel.haveRedBlueLight.value = true;
      }
    }

    //智能电量
    if (result.support_Smart_Electricity_Sleep != null) {
      deviceModel.supportSmartElectricitySleep.value =
          int.tryParse(result.support_Smart_Electricity_Sleep ?? "0") ?? 0;
    }

    ///是否低功耗
    if (int.tryParse(result.support_low_power ?? "0") != 0) {
      /// support_low_power = 3，4，7，8 时，支持超强低功耗（充电后超长待机）
      deviceModel.isSupportLowPower.value = true;
      deviceModel.supportLowPower.value =
          int.tryParse(result.support_low_power ?? "0") ?? 0;

      int supportPower = deviceModel.supportLowPower.value;
      if (supportPower == 3 ||
          supportPower == 4 ||
          supportPower == 7 ||
          supportPower == 8) {
        deviceModel.isSupportDeepLowPower.value = true;
      }
    } else {
      ///长电
      if (int.tryParse(result.support_humanDetect ?? "0")! > 0) {
        print("-----------supportAI---true---------");
        deviceModel.supportAI.value = 1;
      }
    }

    ///新的工作模式按位 [bit 0 -> 低功耗 bit 1 -> 持续工作 bit 2 ->超低功耗 bit 3 ->微功耗]
    if (result.support_new_low_power != null) {
      deviceModel.supportNewLowPower.value =
          int.tryParse(result.support_new_low_power ?? "0") ?? 0;
    }

    if (result.support_Pir_Distance_Adjust != null) {
      deviceModel.supportPirDistanceAdjust.value =
          int.tryParse(result.support_Pir_Distance_Adjust!) ?? 0;
    }

    //TF时间轴
    if (result.support_time_line != null) {
      deviceModel.supportTimeLine.value =
          int.tryParse(result.support_time_line ?? "0") ?? 0;
    }

    if (result.support_mutil_sensor_stream != null) {
      int sensor = int.tryParse(result.support_mutil_sensor_stream ?? "0") ?? 0;
      print("------sensor-----$sensor---------");
      if (sensor == 1 || sensor == 2) {
        //双目
        sensor = 1;
      }
      if (result.splitScreen != null) {
        int splitScreen = int.tryParse(result.splitScreen ?? "0") ?? 0;
        if (splitScreen == 1) {
          sensor = 3;
        } else if (splitScreen == 2) {
          sensor = 4;
        }
        deviceModel.splitScreen.value = splitScreen;
        Manager()
            .getDeviceManager(id: device.id)!
            .setSplitValue(splitScreen, device.id);
      }
      deviceModel.supportMutilSensorStream.value = sensor;
      Manager()
          .getDeviceManager(id: device.id)!
          .setSensorValue(sensor, device.id);
    }

    ///警笛状态 1开，0 关
    Manager()
        .getDeviceManager(id: device.id)!
        .setSirenState(result.sirenStatus == "1");

    ///报警开关 1开，0 关
    Manager()
        .getDeviceManager(id: device.id)!
        .setAlarmStatus(result.alarm_status == "1");

    ///电量
    Manager()
        .getDeviceManager(id: device.id)!
        .setBatteryRate(result.batteryRate ?? "100");

    /// 设备是否支持人形检测
    if (result.support_PeopleDetection != null) {
      Manager().getDeviceManager(id: device.id)!.setIsSupportDetect(
          int.tryParse(result.support_PeopleDetection!)! > 0, device.id);
    }

    if (int.tryParse(result.support_led_hidden_mode ?? "") != null &&
        int.tryParse(result.support_led_hidden_mode ?? "") != 0) {
      deviceModel.isSupportledLight.value = true;
    }

    if (result.support_WhiteLed_Ctrl != null) {
      print(
          "-----白光灯--support_WhiteLed_Ctrl---${result.support_WhiteLed_Ctrl}");
    }

    if (result.support_manual_light != null) {
      ///是否支持手动开关白光灯
      deviceModel.support_manual_light.value = result.support_manual_light!;
      print("-----白光灯--support_manual_light---${result.support_manual_light}");
    }

    ///pixel 像素
    if (result.pixel != null) {
      deviceModel.pixel.value = int.tryParse(result.pixel!) ?? 0;
    }

    ///是否支持像素切换
    if (result.support_pixel_shift != null) {
      deviceModel.support_pixel_shift.value = result.support_pixel_shift!;
    }

    ///是否支持双目
    if (result.support_binocular != null) {
      deviceModel.supportBinocular.value =
          result.support_binocular == "1" ? true : false;
    }

    ///支持AI
    if (result.support_mode_AiDetect != null) {
      print(
          "--------support_mode_AiDetect-------${result.support_mode_AiDetect}-----------------");
      deviceModel.aiDetectMode.value =
          int.tryParse(result.support_mode_AiDetect ?? "0") ?? 0;
    }

    if (result.support_pininpic != null) {
      deviceModel.supportPinInPic.value =
          int.parse(result.support_pininpic ?? "0");
    }

    if (result.support_privacy_pos != null) {
      print(
          "-----support_privacy_pos-------${result.support_privacy_pos}--------");
      deviceModel.support_privacy_pos.value =
          int.tryParse(result.support_privacy_pos ?? "0") ?? 0;
    }

    //人形框定
    if (result.support_humanoidFrame != null) {
      print(
          "-----support_humanoidFrame-------${result.support_humanoidFrame}--------");
      deviceModel.supportHumanoidFrame.value =
          int.tryParse(result.support_humanoidFrame ?? "0") ?? 0;
    }

    ///是否支持人形变倍跟踪
    if (result.support_humanoid_zoom != null) {
      deviceModel.supportHumanoidZoom.value =
          int.tryParse(result.support_humanoid_zoom ?? "0") ?? 0;
    }

    ///是否支持看守卫
    if (result.support_ptz_guard != null) {
      deviceModel.support_ptz_guard.value =
          int.tryParse(result.support_ptz_guard ?? "0") ?? 0;
    }

    ///固件版本
    if (result.sys_ver != null) {
      deviceModel.currentSystemVer.value = result.sys_ver ?? "0";
    }

    ///看守卫设置位置信息
    if (result.preset_value != null) {
      if (deviceModel.presetValue.value !=
          int.tryParse(result.preset_value ?? "0")) {
        deviceModel.presetValue.value =
            int.tryParse(result.preset_value ?? "0") ?? 0;
        var list = deviceModel.presetValue.value
                .toRadixString(2)
                .padLeft(16, '0')
                .substring(0, 5)
                .split('')
                .toList() ??
            [];
        print("---看守卫设置位置信息----${list.toString()}-------");
        deviceModel.presetPositionList.value = list;
      }
    }

    ///自动录像模式
    if (result.support_auto_record_mode != null) {
      deviceModel.supportAutoRecordMode.value =
          int.tryParse(result.support_auto_record_mode ?? '0') ?? 0;
    }

    ///智能侦测定时
    if (result.smartdetecttime != null) {
      deviceModel.smartdetecttime.value = result.smartdetecttime ?? "0";
    }

    ///聚焦功能
    //support_focus=1，表示支持聚焦功能
    //support_focus=2，表示支持聚焦功能，且支持定点变倍
    if (result.support_focus != null) {
      deviceModel.support_focus.value =
          int.tryParse(result.support_focus ?? "0") ?? 0;
    }

    ///多倍变焦和支持最大的变倍数
    if (result.MaxZoomMultiple != null) {
      deviceModel.MaxZoomMultiple.value =
          int.tryParse(result.MaxZoomMultiple ?? "0") ?? 0;
    }

    ///当前变焦倍数
    if (result.CurZoomMultiple != null) {
      deviceModel.CurZoomMultiple.value =
          int.tryParse(result.CurZoomMultiple ?? "1") ?? 1;
    }

    ///TF录像模式
    if (result.recordmod != null) {
      deviceModel.recordmod.value = result.recordmod!;
    }

    if (result.support_mode_AiDetect != null) {
      deviceModel.aiDetectMode.value =
          int.tryParse(result.support_mode_AiDetect ?? "0") ?? 0;
      if (deviceModel.aiDetectMode.value & 0x01 != 0) {
        deviceModel.isSupportAreaIntrusion.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x02 != 0) {
        deviceModel.isSupportPersonStay.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x04 != 0) {
        deviceModel.isSupportIllegalParking.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x08 != 0) {
        deviceModel.isSupportCrossBorder.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x10 != 0) {
        deviceModel.isSupportOffPostMonitor.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x20 != 0) {
        deviceModel.isSupportCarRetrograde.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x40 != 0) {
        deviceModel.isSupportPackageDetect.value = true;
      }

      if (deviceModel.aiDetectMode.value & 0x80 != 0) {
        deviceModel.isSupportFireSmokeDetect.value = true;
      }
    }

    if (result.sys_ver != null) {
      List array = deviceModel.currentSystemVer.value.split(".");
      if (array == null || array.length < 4) {
        array = ['0', '0', '0', '0'];
      }
      String first = array[0];
      String second = array[1];
      String third = array[2];

      if (first == '10' &&
          (second == '62' ||
              second == '63' ||
              second == '64' ||
              second == '65') &&
          third == '120') {
        deviceModel.isSupportVideoCall.value = true;
      }
    }

    if (result.support_full_color_night_vision_mode != null) {
      deviceModel.support_full_color_night_vision_mode.value =
          int.tryParse(result.support_full_color_night_vision_mode ?? "0") ?? 0;
    }
  }

  void showTips(String id) async {
    var deviceModel = Manager().getDeviceManager(id: id)!.deviceModel;
    if (deviceModel == null) return;
    if (deviceModel.connectState.value == DeviceConnectState.password) {
      EasyLoading.showToast("密码错误，请使用正确的密码");
    } else if (deviceModel.connectState.value == DeviceConnectState.offline) {
      EasyLoading.showToast("设备已离线，请唤醒设备重试");
    } else if (deviceModel.connectState.value ==
        DeviceConnectState.disconnect) {
      EasyLoading.showToast("连接中断，请重试！");
    } else if (deviceModel.connectState.value == DeviceConnectState.timeout) {
      EasyLoading.showToast("连接超时，请重试！");
    } else {
      EasyLoading.showToast("连接出错了，请重试！");
    }
  }

  void removeListener() {
    var device = Manager().getDeviceManager()!.mDevice;
    if (device == null) return;
    device.removeListener(statusListener);
    device.removeListener(_connectStateListener);
    device.removeListener(_wakeupStateListener);
  }
}
