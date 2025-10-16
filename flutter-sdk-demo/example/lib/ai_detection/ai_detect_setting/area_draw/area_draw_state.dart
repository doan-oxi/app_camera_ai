import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../../../model/device_model.dart';
import 'package:get/get.dart';

class AiAreaDrawState {
  var aiType = Rx<AiType?>(null);

  var index = 0.obs;

  List<Offset> points1 = [
    Offset(50, 50),
    Offset(150, 50),
    Offset(100, 150),
    Offset(50, 150),
  ];
  List<Offset> points2 = [
    Offset(200, 50),
    Offset(350, 50),
    Offset(350, 150),
  ];
}
