import 'package:get/get.dart';
import '../../model/device_model.dart';
import 'alarm_sound/voice_sound_model.dart';

class AIDetectSettingState {
  var aiType = Rx<AiType?>(null);

  var isOpen = false.obs;

  ///0 出现包裹，1包裹消失，2包裹滞留
  var currentPackageIndex = RxInt(0);

  ///0 火警，1烟雾
  var currentFireSmokeIndex = RxInt(0);

  ///闪光灯设置更新标识
  var flashFlag = RxInt(0);

  ///目标规则设置更新标识
  var targetFlag = RxInt(0);

  ///灵敏度更新标识
  var sensitivityFlag = RxInt(0);

  var deviceSoundModel = Rx<DeviceSoundModel?>(null);

  ///包裹滞留时间， 0-10分钟，1-30分钟，2-1小时，3-6小时，4-12小时，5-24小时，6-48小时，7-72小时
  var stayTimeIndex = RxInt(0);

  ///人员逗留时间或车辆违停时间（秒）
  var stayTime = RxInt(30);

  ///离岗时间（秒）
  var leaveTime = RxInt(30);

  ///区域入侵目标0-人，1-车，2-宠物
  var target0Selected = false.obs;
  var target1Selected = false.obs;
  var target2Selected = false.obs;

  ///1-人，2-车，3-人和车，4-宠物，5-人和宠物，6-车和宠物，7-人、车、宠物
  var targetType = RxInt(1);

  ///最少在岗人数
  var personCount = RxInt(1);

  ///用于控制报警声、闪光灯等设置是否显示
  var isShow = true.obs;

  ///使用场景，0室内，1室外
  var fireSmokeScene = RxInt(0);

  ///侦测定时计划,0全天，1白天，2夜间，3自定义时间段
  var alarmPlan = RxInt(0);
}
