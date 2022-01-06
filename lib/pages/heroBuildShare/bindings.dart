import 'package:get/get.dart';

import 'controller.dart';

class HeroBuildShareBinding extends Bindings {
  HeroBuildShareBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => HeroBuildSharePageController());
  }
}
