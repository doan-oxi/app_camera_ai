import 'dart:async';
import 'package:vsdk_example/ai_detection/ai_detect_setting/alarm_sound/voice_sound_model.dart';
import '../../../model/device_model.dart';
import '../../../utils/device_manager.dart';
import '../../../utils/manager.dart';
import '../../../utils/super_put_controller.dart';
import '../ai_detect_setting_state.dart';

mixin AIAlarmSoundLogic on SuperPutController<AIDetectSettingState> {
  @override
  void initPut() {
    lazyPut<AIAlarmSoundLogic>(this);
    super.initPut();
  }

  VoiceType initVoiceType() {
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        return VoiceType.VoiceTypeAreaIntrusion;
      case AiType.personStay:
        return VoiceType.VoiceTypePersonStay;
      case AiType.illegalParking:
        return VoiceType.VoiceTypeIllegalParking;
      case AiType.crossBorder:
        return VoiceType.VoiceTypeCrossBorder;
      case AiType.offPostMonitor:
        return VoiceType.VoiceTypeOffPostMonitor;
      case AiType.carRetrograde:
        return VoiceType.VoiceTypeCarRetrograde;
      case AiType.packageDetect:
        if (state!.currentPackageIndex.value == 0) {
          return VoiceType.VoiceTypePackageDetect;
        } else if (state!.currentPackageIndex.value == 1) {
          return VoiceType.VoiceTypePackageDisappear;
        } else if (state!.currentPackageIndex.value == 2) {
          return VoiceType.VoiceTypePackageStay;
        }
        return VoiceType.VoiceTypePackageDetect;
      case AiType.areaIntrusion:
        return VoiceType.VoiceTypeAreaIntrusion;
      case AiType.fireSmokeDetect:
        if (state!.currentFireSmokeIndex.value == 0) {
          return VoiceType.VoiceTypeFire;
        } else {
          return VoiceType.VoiceTypeSmoke;
        }
    }
    return VoiceType.VoiceTypeAreaIntrusion;
  }

  getVoiceInfo() async {
    VoiceType type = initVoiceType();
    int vType = getVoiceType(type);
    bool bl = await Manager()
            .getDeviceManager()
            ?.mDevice!
            .customSound
            ?.getVoiceInfo(vType) ??
        false;
    if (bl == true) {
      Map? data = Manager().getDeviceManager()?.mDevice!.customSound?.soundData;
      print("-------getVoiceInfo------data--${data.toString()}------");
      if (data == null) {
        state!.deviceSoundModel.value = null;
      } else {
        state!.deviceSoundModel.value = DeviceSoundModel.fromJson(data);
      }
    } else {
      state!.deviceSoundModel.value = null;
      print("-------getVoiceInfo------false--------");
    }
  }

  openOrCloseVoice(int isOpen, {String playTimes = "3"}) async {
    switch (state!.aiType.value) {
      case AiType.areaIntrusion:
        setAlarmSound(VoiceType.VoiceTypeAreaIntrusion, isOpen,
            playTimes: playTimes);
        break;
      case AiType.personStay:
        setAlarmSound(VoiceType.VoiceTypePersonStay, isOpen,
            playTimes: playTimes);
        break;
      case AiType.illegalParking:
        setAlarmSound(VoiceType.VoiceTypeIllegalParking, isOpen,
            playTimes: playTimes);
        break;
      case AiType.crossBorder:
        setAlarmSound(VoiceType.VoiceTypeCrossBorder, isOpen,
            playTimes: playTimes);
        break;
      case AiType.offPostMonitor:
        setAlarmSound(VoiceType.VoiceTypeOffPostMonitor, isOpen,
            playTimes: playTimes);
        break;
      case AiType.carRetrograde:
        setAlarmSound(VoiceType.VoiceTypeCarRetrograde, isOpen,
            playTimes: playTimes);
        break;
      case AiType.packageDetect:
        if (state!.currentPackageIndex.value == 0) {
          setAlarmSound(VoiceType.VoiceTypePackageDetect, isOpen,
              playTimes: playTimes);
        } else if (state!.currentPackageIndex.value == 1) {
          setAlarmSound(VoiceType.VoiceTypePackageDisappear, isOpen,
              playTimes: playTimes);
        } else if (state!.currentPackageIndex.value == 2) {
          setAlarmSound(VoiceType.VoiceTypePackageStay, isOpen,
              playTimes: playTimes);
        }
        break;
      case AiType.fireSmokeDetect:
        if (state!.currentFireSmokeIndex.value == 0) {
          setAlarmSound(VoiceType.VoiceTypeFire, isOpen, playTimes: playTimes);
        } else {
          setAlarmSound(VoiceType.VoiceTypeSmoke, isOpen, playTimes: playTimes);
        }
        break;
    }
  }

  Future<bool> setVoice(String path, String name, int switchV, int type,
      {bool play = false, String pTimes = "3"}) async {
    bool isSuc = await Manager()
            .getDeviceManager()
            ?.mDevice
            ?.customSound
            ?.setVoiceInfo(path, name, switchV, type,
                playInDevice: play, playTimes: pTimes) ??
        false;
    return isSuc;
  }

  void setAlarmSound(VoiceType type, int isOpen,
      {String playTimes = "3"}) async {
    int vType = getVoiceType(type);

    ///sourcePath可根据需要替换音频文件，demo 只用该音频作示例
    String sourcePath =
        "http://doraemon-hongkong.camera666.com/cn_jinzhi_douliu_1694253028.wav";
    String name = "此区域禁止逗留，请速离开";
    if (isOpen == 0) {
      sourcePath = "";
      name = "跟随系统";
    }
    bool bl =
        await setVoice(sourcePath, name, isOpen, vType, pTimes: playTimes);
    print(
        "-------------------setAlarmSound----isOpen-$isOpen---vType-$vType---------$bl");
    if (bl) {
      DeviceSoundModel? model = state!.deviceSoundModel.value;
      model?.isOpen = isOpen.toString();
      print("---DeviceSoundModel--${model?.isOpen}----------");
      state!.deviceSoundModel.value = null;
      state!.deviceSoundModel.value = model;
    }
  }

  int getVoiceType(VoiceType type) {
    int voiceType = 9;
    switch (type) {
      case VoiceType.VoiceTypeFire:
        voiceType = 7;
        break;
      case VoiceType.VoiceTypeSmoke:
        voiceType = 8;
        break;
      case VoiceType.VoiceTypeAreaIntrusion:

        ///9---区域入侵提示音
        voiceType = 9;
        break;
      case VoiceType.VoiceTypePersonStay:

        ///10---人逗留检测提示音
        voiceType = 10;
        break;
      case VoiceType.VoiceTypeIllegalParking:

        ///11---车违停检测提示音
        voiceType = 11;
        break;
      case VoiceType.VoiceTypeCrossBorder:

        ///12---越线检测提示音
        voiceType = 12;
        break;
      case VoiceType.VoiceTypeOffPostMonitor:

        ///13---离岗检测提示音
        voiceType = 13;
        break;
      case VoiceType.VoiceTypeCarRetrograde:

        ///14---车辆逆行提示音
        voiceType = 14;
        break;
      case VoiceType.VoiceTypePackageDetect:

        ///15---包裹监测
        voiceType = 15;
        break;
      case VoiceType.VoiceTypePackageDisappear:
        voiceType = 16;
        break;
      case VoiceType.VoiceTypePackageStay:
        voiceType = 17;
        break;
      default:
        break;
    }
    return voiceType;
  }
}
