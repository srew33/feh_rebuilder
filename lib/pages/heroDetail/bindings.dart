import 'package:feh_rebuilder/pages/heroDetail/controller.dart';
import 'package:get/get.dart';

class HeroDetailBinding extends Bindings {
  HeroDetailBinding();

  @override
  void dependencies() {
    Get.lazyPut(() => HeroDetailController());
  }
}
