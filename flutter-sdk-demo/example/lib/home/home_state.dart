import 'package:get/get.dart';

class HomeState {
  Rx<List<String>> deviceList = Rx<List<String>>([]);

  RxInt statusRefresh = 0.obs;
}
