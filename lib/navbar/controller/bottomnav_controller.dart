import 'package:get/get.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void onNavTap(int index) {
    selectedIndex.value = index;
  }
}