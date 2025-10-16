///voicetype
///0---人脸侦测报警提 示音
///1---人形侦测报警提 示音
///2---烟感报警提示音
///3---移动侦测报警提 示音
///4---离岗检测提示音
///5---哭声检测提示音
///6---在岗监测提示音
///7---烟火相机火焰提示音
///8---烟火相机烟雾提示音

///9---区域入侵提示音
///10---人逗留检测提示音
///11---车违停检测提示音
///12---越线检测提示音
///13---离岗检测提示音
///14---车辆逆行提示音
///15---包裹出现监测
///16---包裹消失监测
///17---包裹滞留监测
enum VoiceType {
  None,
  FaceRecognition, //人脸侦测报警提
  HumanDetection, //人形侦测报警提
  SmokeDetection, //烟感报警提示音
  MotionDetection, //移动侦测报警提
  DepartureDetection, //离岗检测提示音
  CryingDetection, //哭声检测提示音
  VoiceTypeFire, //烟火相机火焰
  VoiceTypeSmoke, //烟火相机烟雾
  VoiceTypeAreaIntrusion, //区域入侵
  VoiceTypePersonStay, //人员逗留
  VoiceTypeIllegalParking, //车违停
  VoiceTypeCrossBorder, //越线报警
  VoiceTypeOffPostMonitor, //离岗检测
  VoiceTypeCarRetrograde, //车辆逆行
  VoiceTypePackageDetect, //包裹出现
  VoiceTypePackageDisappear, //包裹消失
  VoiceTypePackageStay, //包裹滞留
  VoiceTypeEBicycle, //电动车报警
  VideoCallDeviceSound, //视频呼叫设备呼叫声
}

//{result: 0, cmd: 2135, voicetype: 1, switch: 1, filename: 致爱丽丝, command: 1, uid: VSTJ386954TUVYP}
class DeviceSoundModel {
  String voicetype;
  String isOpen;
  String filename;
  String playTimes;
  String url;

  DeviceSoundModel.fromJson(Map json)
      : this.voicetype = json["voicetype"],
        this.isOpen = json["switch"],
        this.filename = json["filename"],
        this.playTimes = json["playtimes"],
        this.url = json['url'];

  Map toJson() {
    return {
      'voicetype': voicetype,
      'isOpen': isOpen,
      'filename': filename,
      'playtimes': playTimes,
      'url': url,
    };
  }
}
