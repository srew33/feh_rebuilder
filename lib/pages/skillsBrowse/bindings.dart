import 'package:feh_tool/pages/skillsBrowse/controller.dart';
import 'package:get/get.dart';

class SkillsBrowseBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SkillsBrowseController());
  }
}
