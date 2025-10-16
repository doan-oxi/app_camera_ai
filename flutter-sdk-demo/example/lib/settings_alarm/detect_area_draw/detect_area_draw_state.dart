import 'package:get/get.dart';

class DetectAreaDrawState {
  Rx<List<List<int>>> gridState =
      Rx<List<List<int>>>(List.generate(18, (index) => List.filled(22, 1)));

  Rx<List<List<int>>> gridState1 =
      Rx<List<List<int>>>(List.generate(18, (index) => List.filled(22, 1)));

  Rx<List<List<int>>> gridState2 =
      Rx<List<List<int>>>(List.generate(18, (index) => List.filled(22, 1)));

  Rx<List<List<int>>> gridState3 =
      Rx<List<List<int>>>(List.generate(18, (index) => List.filled(22, 1)));
}
