import 'dart:async';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vsdk/app_player.dart';
import 'package:vsdk/camera_device/camera_device.dart';
import 'package:vsdk/camera_device/commands/video_command.dart';
import 'package:vsdk_example/model/device_model.dart';
import 'package:vsdk_example/utils/device.dart';
import 'package:vsdk/camera_player.dart';
import '../../play/play_logic.dart';
import '../../utils/manager.dart';
import '../../utils/permission_util.dart';
import '../../utils/super_put_controller.dart';
import '../settings_main_logic.dart';
import '../settings_main_state.dart';

/// PortraitTalk 控制器
class VideoLogic extends SuperPutController<SettingsMainState> {
  VideoLogic(SettingsMainState state) {
    value = state;
  }

  var cameraStart = false.obs;

  @override
  void onClose() {
    _stopVideo();
    super.onClose();
  }

  void turnOnOffVideoCall() async {
    DeviceModel model = Manager().getDeviceManager()!.deviceModel!;
    if (model.support_privacy_pos.value > 0 &&
        model.privacyFlag.value == true) {
      EasyLoading.showToast('已开启物理遮挡，该功能不可用'.tr);
      return;
    }

    // if (model.connectState.value != DeviceConnectState.connected) {
    //   EasyLoading.showToast('连接中断，请重连'.tr);
    //   return;
    // }

    bool cameraAuthority = await checkCameraPermission();
    if (cameraAuthority != true) {
      EasyLoading.showToast('请先打开相机权限！'.tr);
      return;
    }

    if (!state!.isVideoCall.value) {
      CameraDevice device = Manager().getDeviceManager()!.getDevice()!;
      bool bl = await device.configVideoCallStatus(1);
      print("---video----configVideoCallStatus---$bl----");
      if (bl) {
        model.videoCallConnectState.value = device.videoCallStatus;
      }
      if (model.videoCallConnectState.value == 4) return;

      state!.isVideoCall.value = true;

      ///enableCamera
      SettingsMainLogic mainLogic = Get.find<SettingsMainLogic>();
      bool bl2 = await mainLogic.createVideoPlayer();
      if (bl2) {
        print("--video----create success------");
        AppPlayerController controller =
            Manager().getDeviceManager()!.getController()!;
        bool bl3 = controller.enableCameraPlayer(Manager()
            .getDeviceManager()!
            .getCameraPlayer()!
            .controller
            .playerId);
        print("----video---enableCameraPlayer---$bl3---");
        controller.setVoiceChannel(1);
        if (Get.find<SettingsMainLogic>().state!.voiceState.value !=
            VoiceState.play) _startOrStopTalkPortraitAudio(VoiceState.none);
        0.25.delay(() {
          _startVideo();
        });
      }
    } else {
      state!.isVideoCall.value = false;
      state!.isPhoneCameraFront.value = true;

      _startOrStopTalkPortraitAudio(VoiceState.play);
      0.25.delay(() {
        _stopVideo();
      });
    }
  }

  void _startVideo() async {
    var deviceModel = Manager().getDeviceManager()!.deviceModel!;
    CameraDevice device = Manager().getDeviceManager()!.getDevice()!;
    if (deviceModel.connectState.value != DeviceConnectState.connected) {
      deviceModel.connectState.value = DeviceConnectState.connecting;

      ///重连
      Device().connectDevice(device);
      return;
    }

    ///startCamera
    CameraPlayer cPlayer = Manager().getDeviceManager()!.getCameraPlayer()!;
    await setVideoSource(cPlayer, device.clientPtr!, dir: 0);
    bool bl = await cPlayer.controller.start();
    print("---_startVideo---$bl----");
    if (bl) {
      PlayLogic playLogic = Get.find<PlayLogic>();
      playLogic.state!.cameraPlayer.value = cPlayer;

      cPlayer.progress.value = 0;
      device.configVideoCallStatus(1);
      state!.isPhoneCameraOn.value = true;

      ///设置前置摄像机
      await Manager()
          .getDeviceManager()!
          .getCameraPlayer()!
          .controller
          .flipCamera(1);
      state!.isPhoneCameraFront.value = await Manager()
          .getDeviceManager()!
          .getCameraPlayer()!
          .controller
          .isFrontCamera();
    }
  }

  void setFlipCamera() async {
    if (state!.isPhoneCameraFront.value) {
      await Manager()
          .getDeviceManager()!
          .getCameraPlayer()!
          .controller
          .flipCamera(0);
    } else {
      await Manager()
          .getDeviceManager()!
          .getCameraPlayer()!
          .controller
          .flipCamera(1);
    }
    state!.isPhoneCameraFront.value = await Manager()
        .getDeviceManager()!
        .getCameraPlayer()!
        .controller
        .isFrontCamera();
  }

  Future<bool> setVideoSource(CameraPlayer player, int clientPtr,
      {int dir = 0, int frameRate = 8}) async {
    print("--video----setVideoSource---$clientPtr---");
    if (clientPtr == 0) return false;
    if (clientPtr == player.clientPtr) return true;

    await player.controller.stop();
    //判断清晰度
    var frameRate = 8;
    CameraDevice device = Manager().getDeviceManager()!.getDevice()!;
    if (device.resolution == VideoResolution.low) {
      frameRate = 15;
    } else if (device.resolution == VideoResolution.general) {
      frameRate = 10;
    }

    bool result = await player.controller.setVideoSource(
        CameraVideoSource(clientPtr, dir: dir, frameRate: frameRate));

    if (result == true) {
      player.clientPtr = clientPtr;
    }
    print("--video----setVideoSource---result $result---");
    return result;
  }

  void _stopVideo() async {
    CameraPlayer? cameraPlayer =
        Manager().getDeviceManager()!.getCameraPlayer();
    if (cameraPlayer == null) return;
    cameraPlayer.videoState.value = VideoState.stop;
    await cameraPlayer.controller.stop();
    state!.isPhoneCameraOn.value = false;
    state!.isLocalCameraHidden.value = false;
    PlayLogic playLogic = Get.find<PlayLogic>();
    playLogic.state!.cameraPlayer.value = null;
    Manager().getDeviceManager()!.setCameraPlayer(null);
    CameraDevice device = Manager().getDeviceManager()!.getDevice()!;
    device.configVideoCallStatus(3);
  }

  void _startOrStopTalkPortraitAudio(VoiceState voiceState) async {
    if (Platform.isIOS) {
      var status = await Permission.microphone.status;
      if (status != PermissionStatus.granted) {
        await [Permission.microphone].request();
      }
    }

    var micBool = await checkMicroPhonePermission();
    if (micBool != true) {
      EasyLoading.showToast("请先打开语音权限！");
      return;
    }

    // DeviceModel deviceModel = Manager().getDeviceManager()!.getDeviceModel()!;
    if (micBool == true) {
      // var player = state.player.value;
      if (voiceState == VoiceState.none || voiceState == VoiceState.stop) {
        state!.talkStart.value = true;

        ///停止警笛
        if (Get.find<SettingsMainLogic>().state!.siren.value == true) {
          Get.find<SettingsMainLogic>().sirenCommand(false);
        }

        ///打开语音通话
        bool bl = await Get.find<SettingsMainLogic>().startTalk();
        if (bl) {
          Get.find<PlayLogic>().state!.videoVoiceStop.value = false;
        }
        state!.talkStart.value = false;
      } else if (voiceState == VoiceState.play) {
        bool bl = await Get.find<SettingsMainLogic>().stopTalk();
        if (bl) {
          Get.find<PlayLogic>().state!.videoVoiceStop.value = true;
        }
        // await Get.find<ILivePlayerProvider>().checkAutoVoicePlayer(player);
      }
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
