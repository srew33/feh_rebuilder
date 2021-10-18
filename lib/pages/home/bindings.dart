import 'package:feh_rebuilder/pages/home/controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  HomeBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
