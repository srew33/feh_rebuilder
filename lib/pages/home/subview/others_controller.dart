import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:get/get.dart';

class OthersPageController extends GetxController {
  OthersPageController();

  DataService data = Get.find<DataService>();

  Map<String, int> otherList = const {
    "武器": 0,
    "辅助技能": 1,
    "奥义": 2,
    "技能A": 3,
    "技能B": 4,
    "技能C": 5,
    "圣印": 6,
    "祝福": 15,
    // "双界技能": 8
  };

  final currentLanguage = "".obs;

  // final appVersion = "".obs;
  // final dataVersion = "".obs;
  String appVersion = "";
  String dataVersion = "";

  /// 切换语言
  void switchLanguage(int localeIndex) {
    DataService data = Get.find<DataService>();
    if (localeIndex == -1) {
      currentLanguage.value = data.customBox.read("dataLanguage");
    } else {
      currentLanguage.value = data.languageDict.keys.toList()[localeIndex];
      try {
        Get.updateLocale(data.languageDict.values.toList()[localeIndex]);
        data.customBox.write("dataLanguage", currentLanguage.value);
      } catch (e) {
        Utils.debug(
            "切换语言失败 from${currentLanguage.value} to ${data.languageDict.values.toList()[localeIndex]}");
      }
    }
  }

  @override
  void onInit() {
    switchLanguage(-1);
    appVersion = data.version;
    dataVersion = data.customBox.read("dataVersion") as String;
    super.onInit();
  }
}
