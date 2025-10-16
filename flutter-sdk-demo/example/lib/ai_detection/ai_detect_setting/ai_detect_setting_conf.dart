import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../model/device_model.dart';
import 'ai_detect_setting_bind.dart';
import 'ai_detect_setting_page.dart';

class AIDetectSettingArgs {
  AiType aiType;

  AIDetectSettingArgs(this.aiType);
}

class AIDetectSettingConf {
  static final GetPage getPage = GetPage(
      name: AppRoutes.aiDetectSetting,
      page: () => AIDetectSettingPage(),
      binding: AIDetectSettingBind());

  static GetPageRoute? _pageRoute;

  /// 用于代码进行页面导航
  /// `Get.to()`
  static Widget getWidget(BuildContext context) {
    if (_pageRoute == null) {
      _pageRoute = getPage.createRoute(context) as GetPageRoute?;
    }
    return _pageRoute?.buildPage(context, _pageRoute!.createAnimation(),
            _pageRoute!.createAnimation()) ??
        Container();
  }

  static void dispose() {
    // _pageRoute?.dispose();
    _pageRoute = null;
  }
}
