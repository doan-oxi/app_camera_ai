import 'package:vsdk/camera_device/camera_device.dart';
import 'package:vsdk/camera_device/commands/camera_command.dart';
import 'package:vsdk/camera_device/commands/status_command.dart';
import 'package:vsdk/camera_device/commands/video_command.dart';
import 'package:vsdk_example/play/play_logic.dart';
import 'package:vsdk_example/settings_normal/settings_normal_state.dart';
import 'package:vsdk_example/utils/device_manager.dart';
import 'package:get/get.dart';
import '../model/device_model.dart';
import '../utils/manager.dart';
import '../utils/super_put_controller.dart';
import '../widget/voice_slider/voice_slider_widget.dart';

class SettingsNormalLogic extends SuperPutController<SettingsNormalState> {
  SettingsNormalLogic() {
    value = SettingsNormalState();
  }

  @override
  void onInit() {
    getPowerMode();
    getLedLightHidden();
    if (Manager().getDeviceManager()!.deviceModel!.supportPinInPic.value == 1 ||
        Manager()
                .getDeviceManager()!
                .deviceModel!
                .supportMutilSensorStream
                .value ==
            1) {
      getLinkableEnable();
    }
    Manager().getDeviceManager()!.mDevice!.getRecordParam();
    getInitState();
    getAllStatus();
    getScreenTime();
    getBrightnessValue();
    super.onInit();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  ///初始化省电模式数据
  void getPowerMode() async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice!
            .powerCommand
            ?.getPowerMode() ??
        false;
    PowerMode? powerM =
        Manager().getDeviceManager()!.mDevice!.powerCommand?.powerMode;
    print("----bl--$bl---------getPowerMode-----------powerM:$powerM");
    if (powerM == PowerMode.none) {
      Manager().getDeviceManager()!.deviceModel?.lowMode.value = LowMode.none;
      state?.lowMode.value = LowMode.none;
    } else if (powerM == PowerMode.low) {
      Manager().getDeviceManager()!.deviceModel?.lowMode.value = LowMode.low;
      state?.lowMode.value = LowMode.low;
    } else if (powerM == PowerMode.veryLow) {
      Manager().getDeviceManager()!.deviceModel?.lowMode.value =
          LowMode.veryLow;
      state?.lowMode.value = LowMode.veryLow;
    }
  }

  ///开启省电模式
  void onClickSavePowerMode() async {
    ///打开省电模式
    controlLowPowerMode(LowMode.low);

    ///关闭智能省电模式
    closeSmartElectricity();
  }

  ///开启持续工作模式
  void onClickKeepWorkMode() async {
    //持续工作模式，设备不睡眠，一直工作，电池很快就会消耗完
    ///打开持续工作模式
    controlLowPowerMode(LowMode.none);

    ///关闭智能省电模式
    closeSmartElectricity();
  }

  ///开启超级省电模式
  void onClickVeryLowPowerMode() async {
    //超级省电模式，摄像机处于超级省电模式，只有运动侦测才会唤醒设备，App无法唤醒设备。此模式电池电力消耗最少
    ///打开超级省电模式
    controlLowPowerMode(LowMode.veryLow);

    ///关闭智能省电模式
    closeSmartElectricity();
  }

  void closeSmartElectricity() {
    if (Manager()
            .getDeviceManager()!
            .deviceModel!
            .supportSmartElectricitySleep
            .value ==
        1) {
      ///关闭智能省电模式
      setSmartElectricitySleep(0, 50);
    }
  }

  ///省电模式设置
  void controlLowPowerMode(LowMode lowMode) async {
    PowerMode powerMode = PowerMode.none;
    if (lowMode == LowMode.none) {
      powerMode = PowerMode.none;
    } else if (lowMode == LowMode.low) {
      powerMode = PowerMode.low;
    } else if (lowMode == LowMode.veryLow) {
      powerMode = PowerMode.veryLow;
    }
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice!
            .powerCommand
            ?.controlPower(powerMode) ??
        false;
    if (bl) {
      Manager().getDeviceManager()!.deviceModel!.lowMode.value = lowMode;
      state?.lowMode.value = lowMode;
      print("设置成功");
    } else {
      print("设置失败");
    }
  }

  ///智能省电（微功耗）开关设置
  void setSmartElectricitySleep(int switchV, int threshold) async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice!
            .powerCommand
            ?.setSmartElectricitySleep(switchV,
                electricityThreshold: threshold) ??
        false;
    if (bl) {
      Manager()
          .getDeviceManager()!
          .deviceModel
          ?.smartElectricitySleepSwitch
          .value = switchV == 1;
      state?.smartElecSwitch.value = switchV == 1;
      print("智能省电（微功耗）设置成功");
    }
  }

  ///指示灯隐藏开关
  void ledLightHidden(bool hidden) async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice
            ?.ledCommand
            ?.controlLed(hidden) ??
        false;
    if (bl) {
      Manager().getDeviceManager()!.deviceModel?.ledLight.value = hidden;
      state?.ledHidden.value = hidden;
    }
  }

  ///获取指示灯隐藏状态
  void getLedLightHidden() async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice
            ?.ledCommand
            ?.getLedState() ??
        false;
    if (bl) {
      Manager().getDeviceManager()!.deviceModel?.ledLight.value =
          Manager().getDeviceManager()!.mDevice?.ledCommand?.hideLed ?? false;
      state?.ledHidden.value =
          Manager().getDeviceManager()!.mDevice?.ledCommand?.hideLed ?? false;
    }
  }

  void onVoiceClick() async {
    Get.bottomSheet(VoiceSliderWidget());
  }

  Future<bool> getInitState() async {
    bool bl =
        await Manager().getDeviceManager()!.mDevice?.getCameraParams() ?? false;
    if (bl) {
      state?.microphoneVoice.value =
          Manager().getDeviceManager()!.mDevice?.involume?.toDouble() ?? 0;
      state?.hornVoice.value =
          Manager().getDeviceManager()!.mDevice?.outvolume?.toDouble() ?? 0;
      state?.is60Hz.value =
          Manager().getDeviceManager()!.mDevice?.lightMode == 1;
      state?.isOverturn.value =
          Manager().getDeviceManager()!.mDevice?.direction.index == 3;
    }
    return bl;
  }

  void getAllStatus() async {
    StatusResult? result =
        await Manager().getDeviceManager()!.mDevice?.getStatus(cache: false);
    state!.isTimeOSD.value = result?.osdenable == "1";
  }

  ///获取联动开关状态
  getLinkableEnable() async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice!
            .qiangQiuCommand
            ?.getLinkageEnable() ??
        false;
    if (bl) {
      state!.linkableSwitch.value = Manager()
              .getDeviceManager()!
              .mDevice!
              .qiangQiuCommand
              ?.gblinkage_enable ==
          1;
    }
  }

  ///控制联动校正开关
  controlLinkableEnable(bool enable) async {
    bool bl = await Manager()
            .getDeviceManager()!
            .mDevice!
            .qiangQiuCommand
            ?.controlLinkageEnable(enable ? 1 : 0) ??
        false;
    if (bl) {
      state!.linkableSwitch.value = enable;
      PlayLogic playLogic = Get.find<PlayLogic>();
      playLogic.state!.isLinkableOpen.value = enable;
    }
  }

  ///设置视频画面是否翻转
  void setCameraDirection(bool isOverturn) async {
    VideoDirection direction = VideoDirection.none;
    if (isOverturn) {
      direction = VideoDirection.mirrorAndFlip;
    }
    bool bl =
        await Manager().getDeviceManager()!.mDevice!.changeDirection(direction);
    if (bl) {
      state!.isOverturn(isOverturn);
    }
  }

  ///灯光抗干扰
  void setLightMode(bool is60Hz) async {
    bool bl = await Manager()
        .getDeviceManager()!
        .mDevice!
        .changeLightMode(is60Hz ? 1 : 0);
    if (bl) {
      state!.is60Hz(is60Hz);
    }
  }

  ///视频时间显示开关
  void setVideoTimeOsd(bool isTimeOSD) async {
    print("-----setVideoTimeOsd---$isTimeOSD-------------");
    bool bl = await Manager()
        .getDeviceManager()!
        .mDevice!
        .changeShowTime(isTimeOSD ? 1 : 0);
    if (bl) {
      print("-----setVideoTimeOsd---success-----------");
      state!.isTimeOSD(isTimeOSD);
    }
  }

  void setScreenTime(int index) async {
    CameraDevice device = Manager().getDeviceManager()!.mDevice!;
    DeviceModel model = Manager().getDeviceManager()!.deviceModel!;
    if (index == 7) {
      ///暗黑模式
      var result = await device.setVideoCallScreenSleepTime(1, 10);
      if (result == true) {
        var re = await device.setVideoCallScreenMode(1);
        model.videoCallScreenSleepTime.value = device.sleepTime;
        model.videoCallScreenSleepFlag.value = device.sleepFlag;
        if (re) {
          state!.screenTimeIndex.value = index;
          print("setScreenTime 设置成功");
        } else {
          print("setScreenTime 设置失败");
        }
      } else {
        print("setScreenTime 设置失败");
      }
    } else {
      ///默认30s
      int flag = 0;
      int time = 30;
      if (index == 6) {
        ///永不熄屏
        flag = 1;
        time = 10;
      } else if (index != 0) {
        ///1-5分钟
        time = index * 60;
      }
      if (model.videoCallScreenMode.value == 1) {
        var result = await device.setVideoCallScreenMode(0);
        if (result != true) {
          print("setScreenTime 设置失败");
          return;
        }
      }
      var result = await device.setVideoCallScreenSleepTime(flag, time);
      if (result) {
        state!.screenTimeIndex.value = index;
        print("setScreenTime 设置成功");
      } else {
        print("setScreenTime 设置失败");
      }
    }
  }

  void getScreenTime() async {
    CameraDevice device = Manager().getDeviceManager()!.mDevice!;
    DeviceModel model = Manager().getDeviceManager()!.deviceModel!;
    var result = await device.getVideoCallScreenMode();
    if (result == true) {
      model.videoCallScreenMode.value = device.blackMode;
    }

    var result2 = await device.getVideoCallScreenSleepTime();
    if (result2 == true) {
      model.videoCallScreenSleepTime.value = device.sleepTime;
      model.videoCallScreenSleepFlag.value = device.sleepFlag;
    }

    state!.screenTimeIndex.value = 1;

    if (model.videoCallScreenMode.value == 1) {
      state!.screenTimeIndex.value = 7;
    } else if (model.videoCallScreenSleepFlag.value == 1) {
      state!.screenTimeIndex.value = 6;
    } else {
      switch (model.videoCallScreenSleepTime.value) {
        case 30:
          state!.screenTimeIndex.value = 0;
          break;
        case 60:
          state!.screenTimeIndex.value = 1;
          break;
        case 120:
          state!.screenTimeIndex.value = 2;
          break;
        case 180:
          state!.screenTimeIndex.value = 3;
          break;
        case 240:
          state!.screenTimeIndex.value = 4;
          break;
        case 300:
          state!.screenTimeIndex.value = 5;
          break;
        default:
          state!.screenTimeIndex.value = 1;
          break;
      }
    }
  }

  void setBrightness() async {
    CameraDevice device = Manager().getDeviceManager()!.mDevice!;
    DeviceModel model = Manager().getDeviceManager()!.deviceModel!;
    var result = await device
        .setVideoCallScreenBrightness(state!.currentBrightnessValue.value);
    if (result == true) {
      print("setBrightness 设置成功");
      model.videoCallScreenBrightness.value = device.videoCallScreenBrightness;
      Get.back();
    } else {
      state!.currentBrightnessValue.value =
          model.videoCallScreenBrightness.value;
      print("setBrightness 设置失败");
    }
  }

  void cancelSet() {
    state!.currentBrightnessValue.value = Manager()
        .getDeviceManager()!
        .deviceModel!
        .videoCallScreenBrightness
        .value;
    Get.back();
  }

  void getBrightnessValue() async {
    CameraDevice device = Manager().getDeviceManager()!.mDevice!;
    DeviceModel model = Manager().getDeviceManager()!.deviceModel!;
    var result = await device.getVideoCallScreenBrightness();
    if (result == true) {
      model.videoCallScreenBrightness.value = device.videoCallScreenBrightness;
      state!.currentBrightnessValue.value =
          model.videoCallScreenBrightness.value;
    }
  }
}
