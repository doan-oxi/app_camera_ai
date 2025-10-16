import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';

class AIDetectModel {
  AIDetectModel();

  var enable = 0.obs; //功能开关
  var region; //警戒区域
  var sensitive = 1.obs; //灵敏度
  var lightLed = 0.obs; //报警白光灯动作
  var alarmLed = 0.obs; //报警红蓝报警灯动作
  var areaframe = 1.obs;

  double xTransformToDraw(double x) {
    final media = MediaQuery.of(Get.context!);
    return x * media.size.width;
  }

  double yTransformToDraw(double y) {
    final media = MediaQuery.of(Get.context!);
    return y * media.size.width * 9 / 16;
  }

  double xTransformToServer(double x) {
    final media = MediaQuery.of(Get.context!);
    var temp = x / media.size.width;
    return double.parse(temp.toStringAsFixed(6));
  }

  double yTransformToServer(double y) {
    final media = MediaQuery.of(Get.context!);
    var temp;
    if (Get.mediaQuery.orientation == Orientation.landscape) {
      temp = y / media.size.height;
    } else {
      temp = y / (media.size.width * 9 / 16);
    }
    return double.parse(temp.toStringAsFixed(6));
  }
}

class AreaIntrusionModel extends AIDetectModel {
  AreaIntrusionModel();

  var object = 1.obs; //检测对象
  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, Map<String, Map<String, double>>>{};

  AreaIntrusionModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    object.value = json['object'] ?? 1;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, Map<String, Map<String, double>>>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;

        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);

        targetPointsMap['$j'] = {'x': x, 'y': y};
      }
      targetAreaMap['$i'] = targetPointsMap;
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "0": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
      };
      areaMap.addAll(defaultMap);
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var pointsList = <Map>[];
      element.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });
      regionList.add({'point': pointsList});
    });
    json['region'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;
    json['areaMap'] = areaMap;
    return jsonEncode(json);
  }
}

class IllegalParkingModel extends AIDetectModel {
  IllegalParkingModel();

  var staytime = 30.obs; //最大停留时间
  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, Map<String, Map<String, double>>>{};

  IllegalParkingModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    staytime.value = json['staytime'] ?? 30;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, Map<String, Map<String, double>>>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;
        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);
        targetPointsMap['$j'] = {'x': x, 'y': y};
      }
      targetAreaMap['$i'] = targetPointsMap;
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "0": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
      };
      areaMap.addAll(defaultMap);
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['staytime'] = staytime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var pointsList = <Map>[];
      element.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });
      regionList.add({'point': pointsList});
    });
    json['region'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['staytime'] = staytime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class PersonStayModel extends AIDetectModel {
  PersonStayModel();

  var staytime = 30.obs; //最大停留时间
  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, Map<String, Map<String, double>>>{};

  PersonStayModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    staytime.value = json['staytime'] ?? 30;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, Map<String, Map<String, double>>>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;
        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);
        targetPointsMap['$j'] = {'x': x, 'y': y};
      }

      targetAreaMap['$i'] = targetPointsMap;
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "0": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
      };
      areaMap.addAll(defaultMap);
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['staytime'] = staytime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var pointsList = <Map>[];
      element.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });
      regionList.add({'point': pointsList});
    });
    json['region'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['staytime'] = staytime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class OffPostMonitorModel extends AIDetectModel {
  OffPostMonitorModel();

  var sumperson = 1.obs; //在岗人数
  var leavetime = 100.obs; //最大离开时间
  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, Map<String, Map<String, double>>>{};

  OffPostMonitorModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    sumperson.value = json['sumperson'] ?? 1;
    leavetime.value = json['leavetime'] ?? 100;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, Map<String, Map<String, double>>>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;
        // var x = xTransformToDraw(point['x'] as double);
        // var y = yTransformToDraw(point['y'] as double);
        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);
        targetPointsMap['$j'] = {'x': x, 'y': y};
      }

      targetAreaMap['$i'] = targetPointsMap;
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "0": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
      };
      areaMap.addAll(defaultMap);
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['sumperson'] = sumperson.value;
    json['leavetime'] = leavetime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var pointsList = <Map>[];
      element.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });
      regionList.add({'point': pointsList});
    });
    json['region'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['sumperson'] = sumperson.value;
    json['leavetime'] = leavetime.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class CarRetrogradeModel extends AIDetectModel {
  CarRetrogradeModel();

  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, dynamic>{};

  CarRetrogradeModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, dynamic>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;

        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);

        targetPointsMap['$j'] = {'x': x, 'y': y};
      }

      int selectedLine = 0;
      var exitMap = areaList[i]['exitline'];
      for (int k = 0; k < points.length; k++) {
        var point = points[k] as Map;

        var tempX = point['x'];
        var tempY = point['y'];

        if (exitMap?['start_x'] == tempX && exitMap?['start_y'] == tempY) {
          selectedLine = k;
          break;
        }
      }

      print('==>>匹配到的selectedLine:$selectedLine');
      targetAreaMap['$i'] = {
        'point': targetPointsMap,
        'selectedLine': selectedLine
      };
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "point": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
        'selectedLine': 2,
      };
      areaMap['0'] = defaultMap;
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var carArea = element['point'] as Map;
      var selectedLine = element['selectedLine'] as int;

      var pointsList = <Map>[];
      carArea.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });

      var tempA, tempB;
      if (selectedLine >= 0 && selectedLine < 3) {
        tempA = pointsList[selectedLine];
        tempB = pointsList[selectedLine + 1];
      } else {
        tempA = pointsList[3];
        tempB = pointsList[0];
      }

      regionList.add({
        'point': pointsList,
        'exitline': {
          "start_x": tempA['x'],
          "start_y": tempA['y'],
          "end_x": tempB['x'],
          "end_y": tempB['y']
        }
      });
    });
    json['region'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class CrossBorderModel extends AIDetectModel {
  CrossBorderModel();

  var object = 1.obs; //检测对象
  var crosslineArr; //越界区域数组
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, dynamic>{};

  CrossBorderModel.fromJson(Map<String, dynamic> json) {
    enable.value = json['enable'] ?? 0;
    object.value = json['object'] ?? 1;
    crosslineArr = json['crosslineArr'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, dynamic>();
    var areaList = crosslineArr as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;
      for (int j = 0; j < 2; j++) {
        var point = points[j] as Map;

        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        final media = MediaQuery.of(Get.context!);
        var height = media.size.width * 9 / 16;

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);
        // if (y == 0.0) {
        //   y = 2.0;
        // }
        //
        // if ( (y - height).abs() < 0.1) {
        //   y = height - 2.0;
        // }
        targetPointsMap['$j'] = {'x': x, 'y': y};
      }

      //根据最后一个点 判断dir的值
      Point a = Point(
          targetPointsMap['0']?['x'] as num, targetPointsMap['0']?['y'] as num);
      Point b = Point(
          targetPointsMap['1']?['x'] as num, targetPointsMap['1']?['y'] as num);

      Point middle = Point((a.x + b.x) / 2, (a.y + b.y) / 2);

      var pointD = points[3] as Map;

      var tempXD = pointD['x'];
      var tempYD = pointD['y'];
      if (tempXD is int) {
        tempXD = (tempXD).toDouble();
      }
      if (tempYD is int) {
        tempYD = (tempYD).toDouble();
      }
      var xD = xTransformToDraw(tempXD as double);
      var yD = yTransformToDraw(tempYD as double);

      int dir = 1;
      if (xD > middle.x) {
        dir = 1;
      } else if (xD < middle.x) {
        dir = 0;
      } else {
        if (yD > middle.y) {
          dir = 0;
        } else {
          dir = 1;
        }
      }

      targetAreaMap['$i'] = {'point': targetPointsMap, 'dir': dir};
    }

    //赋值
    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;
      var padding = 0.0;
      var defaultMap = {
        "0": {
          "0": {"x": media.size.width / 2, "y": 0 + padding},
          "1": {"x": media.size.width / 2, "y": height - padding}
        },
        'dir': 1,
      };
      areaMap['0'] = defaultMap;
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var crossArea = element['point'] as Map;
      var dir = element['dir'] as int;

      var pointsList = <Map>[];
      crossArea.values.forEach((item) {
        var x = item['x'];
        var y = item['y'];
        pointsList.add({'x': x, 'y': y});
      });

      Point a = Point((pointsList[0])['x'], (pointsList[0])['y']);
      Point b = Point((pointsList[1])['x'], (pointsList[1])['y']);

      Point middle = Point((a.x + b.x) / 2, (a.y + b.y) / 2);
      pointsList.add({'x': (a.x + b.x) / 2, 'y': (a.y + b.y) / 2}); //第三个点

      num dx = a.x - b.x;
      num dy = a.y - b.y;
      double length = sqrt(dx * dx + dy * dy);
      double nx = -dy / length;
      double ny = dx / length;

      double fixedLength = 50.0;

      Point targetA, targetB;
      targetA = Point(middle.x + nx * fixedLength, middle.y + ny * fixedLength);
      targetB = Point(middle.x - nx * fixedLength, middle.y - ny * fixedLength);

      if (dir > 0) {
        if (targetA.x > targetB.x) {
          pointsList.add({'x': targetA.x, 'y': targetA.y}); //第四个点
        } else if (targetA.x < targetB.x) {
          pointsList.add({'x': targetB.x, 'y': targetB.y}); //第四个点
        } else {
          if (targetA.y > targetB.y) {
            pointsList.add({'x': targetB.x, 'y': targetB.y}); //第四个点
          } else {
            pointsList.add({'x': targetA.x, 'y': targetA.y}); //第四个点
          }
        }
      } else {
        if (targetA.x > targetB.x) {
          pointsList.add({'x': targetB.x, 'y': targetB.y}); //第四个点
        } else if (targetA.x < targetB.x) {
          pointsList.add({'x': targetA.x, 'y': targetA.y}); //第四个点
        } else {
          if (targetA.y > targetB.y) {
            pointsList.add({'x': targetA.x, 'y': targetA.y}); //第四个点
          } else {
            pointsList.add({'x': targetB.x, 'y': targetB.y}); //第四个点
          }
        }
      }

      var pointsListTarget = <Map>[];
      pointsList.forEach((element) {
        var x = xTransformToServer(element['x']);
        var y = yTransformToServer(element['y']);
        pointsListTarget.add({'x': x, 'y': y});
      });

      regionList.add({'point': pointsListTarget});
    });
    json['crosslineArr'] = regionList;

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class PackageDetectModel extends AIDetectModel {
  PackageDetectModel();

  // var object = 1.obs; //检测对象
  // var region; //警戒区域
  // var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  // var alarmLed = 0.obs; //报警红蓝报警灯动作
  Map areaMap = <String, Map<String, Map<String, double>>>{};
  var appearEnable = 0.obs;
  var appearLightLed = 0.obs;
  var disappearEnable = 0.obs;
  var disappearLightLed = 0.obs;
  var stayEnable = 0.obs;
  var stayLightLed = 0.obs;
  var stayTime = 3600.obs;

  PackageDetectModel.fromJson(Map<String, dynamic> json) {
    // enable.value = json['enable'] ?? 0;
    // object.value = json['object'] ?? 1;
    region = json['region'] ?? [];
    sensitive.value = json['sensitive'] ?? 1;
    // lightLed.value = json['lightLed'] ?? 0;
    alarmLed.value = json['alarmLed'] ?? 0;
    appearEnable.value = (json['appear'] as Map)['appearEnable'] ?? 0;
    appearLightLed.value = (json['appear'] as Map)['appearLightLed'] ?? 0;
    disappearEnable.value = (json['disappear'] as Map)['disappearEnable'] ?? 0;
    disappearLightLed.value =
        (json['disappear'] as Map)['disappearLightLed'] ?? 0;
    stayEnable.value = (json['stay'] as Map)['stayEnable'] ?? 0;
    stayLightLed.value = (json['stay'] as Map)['stayLightLed'] ?? 0;
    stayTime.value = (json['stay'] as Map)['stayTime'] ?? 30;
    areaframe.value = json['areaframe'] ?? 0;

    var targetAreaMap = Map<String, Map<String, Map<String, double>>>();
    var areaList = region as List;
    for (int i = 0; i < areaList.length; i++) {
      var targetPointsMap = Map<String, Map<String, double>>(); //map list

      var points = areaList[i]['point'] as List;

      for (int j = 0; j < points.length; j++) {
        var point = points[j] as Map;

        var tempX = point['x'];
        var tempY = point['y'];
        if (tempX is int) {
          tempX = (tempX).toDouble();
        }

        if (tempY is int) {
          tempY = (tempY).toDouble();
        }

        var x = xTransformToDraw(tempX as double);
        var y = yTransformToDraw(tempY as double);

        targetPointsMap['$j'] = {'x': x, 'y': y};
      }
      targetAreaMap['$i'] = targetPointsMap;
    }

    if (targetAreaMap.isNotEmpty) {
      areaMap.addAll(targetAreaMap);
    } else {
      final media = MediaQuery.of(Get.context!);
      var height = media.size.width * 9 / 16;

      var padding = 0.0;

      var defaultMap = {
        "0": {
          "0": {"x": 0.0 + padding, "y": 0.0 + padding},
          "1": {"x": 0.0 + padding, "y": height - padding},
          "2": {"x": media.size.width - padding, "y": height - padding},
          "3": {"x": media.size.width - padding, "y": 0.0 + padding}
        },
      };
      areaMap.addAll(defaultMap);
    }
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    // json['enable'] = enable.value;
    // json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    // json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaframe'] = areaframe.value;

    var regionList = <Map>[];
    areaMap.values.forEach((element) {
      var pointsList = <Map>[];
      element.values.forEach((item) {
        var x = xTransformToServer(item['x']);
        var y = yTransformToServer(item['y']);
        pointsList.add({'x': x, 'y': y});
      });
      regionList.add({'point': pointsList});
    });
    json['region'] = regionList;

    json['appear'] = {
      'appearEnable': appearEnable.value,
      'appearLightLed': appearLightLed.value
    };
    json['disappear'] = {
      'disappearEnable': disappearEnable.value,
      'disappearLightLed': disappearLightLed.value
    };
    json['stay'] = {
      'stayEnable': stayEnable.value,
      'stayLightLed': stayLightLed.value,
      'stayTime': stayTime.value
    };

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['enable'] = enable.value;
    // json['object'] = object.value;
    json['sensitive'] = sensitive.value;
    json['lightLed'] = lightLed.value;
    json['alarmLed'] = alarmLed.value;
    json['areaMap'] = areaMap;
    json['appear'] = {
      'appearEnable': appearEnable.value,
      'appearLightLed': appearLightLed.value
    };
    json['disappear'] = {
      'disappearEnable': disappearEnable.value,
      'disappearLightLed': disappearLightLed.value
    };
    json['stay'] = {
      'stayEnable': stayEnable.value,
      'stayLightLed': stayLightLed.value,
      'stayTime': stayTime.value
    };
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}

class FireSmokeDetectModel extends AIDetectModel {
  FireSmokeDetectModel();

  var sensitive = 1.obs; //灵敏度
  // var lightLed = 0.obs; //报警白光灯动作
  var alarmLed = 0.obs; //报警红蓝报警灯动作
  var fireEnable = 0.obs;
  var fireLightLed = 0.obs;
  var smokeEnable = 1.obs;
  var smokeLightLed = 0.obs;
  var firePlace = 0.obs;

  FireSmokeDetectModel.fromJson(Map<String, dynamic> json) {
    sensitive.value = json['sensitive'] ?? 1;
    alarmLed.value = json['alarmLed'] ?? 0;
    fireEnable.value = (json['fire'] as Map)['fireEnable'] ?? 0;
    fireLightLed.value = (json['fire'] as Map)['fireLightLed'] ?? 0;
    smokeEnable.value = (json['smoke'] as Map)['smokeEnable'] ?? 0;
    smokeLightLed.value = (json['smoke'] as Map)['smokeLightLed'] ?? 0;
    firePlace.value = json['firePlace'] ?? 0;
    areaframe.value = json['areaframe'] ?? 0;
  }

  String toJsonString() {
    var json = <String, dynamic>{};
    json['sensitive'] = sensitive.value;
    json['alarmLed'] = alarmLed.value;
    json['firePlace'] = firePlace.value; //0 室内 1 室外
    json['areaframe'] = areaframe.value;

    json['fire'] = {
      'fireEnable': fireEnable.value,
      'fireLightLed': fireLightLed.value
    };
    json['smoke'] = {
      'smokeEnable': smokeEnable.value,
      'smokeLightLed': smokeLightLed.value
    };

    return jsonEncode(json);
  }

  @override
  String toString() {
    var json = <String, dynamic>{};
    json['sensitive'] = sensitive.value;
    json['alarmLed'] = alarmLed.value;
    json['firePlace'] = firePlace.value; //0 室内 1 室外

    json['fire'] = {
      'fireEnable': fireEnable.value,
      'fireLightLed': fireLightLed.value
    };
    json['smoke'] = {
      'smokeEnable': smokeEnable.value,
      'smokeLightLed': smokeLightLed.value
    };
    json['areaframe'] = areaframe.value;

    return jsonEncode(json);
  }
}
