import 'package:feh_rebuilder/data_service.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

///文件里面对应关系如下：
///人物名称:MPID
class Translation extends Translations {
  GetStorage trans = Get.find<DataService>().transBox;
  final Map<String, Map<String, String>> _custom = {
    "en_US": {
      "CUSTOM_STATS_HP": "HP",
      "CUSTOM_STATS_ATK": "ATK",
      "CUSTOM_STATS_SPD": "SPD",
      "CUSTOM_STATS_DEF": "DEF",
      "CUSTOM_STATS_RES": "RES",
    },
    "ja_JP": {
      "CUSTOM_STATS_HP": "HP",
      "CUSTOM_STATS_ATK": "ATK",
      "CUSTOM_STATS_SPD": "SPD",
      "CUSTOM_STATS_DEF": "DEF",
      "CUSTOM_STATS_RES": "RES",
    },
    "zh_TW": {
      "CUSTOM_STATS_HP": "血量",
      "CUSTOM_STATS_ATK": "攻擊",
      "CUSTOM_STATS_SPD": "速度",
      "CUSTOM_STATS_DEF": "防守",
      "CUSTOM_STATS_RES": "魔防",
    }
  };

  @override
  Map<String, Map<String, String>> get keys {
    Map<String, Map<String, String>> _ = Map.fromIterables(
        trans.getKeys() as Iterable<String>,
        (trans.getValues() as Iterable<dynamic>).map((e) =>
            (e as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value as String))));
    _custom.forEach((key, value) {
      _[key]!.addAll(value);
    });
    return _;
  }
}

// 如果需要将软件locale和数据的翻译分开，可以用下面的方式，然后修改.tr为.dTrans
// extension DataTranslation on String {
//   static final Map<String, Map<String, String>> _trans = Map.fromIterables(
//       Get.find<DataService>().transBox.getKeys() as Iterable<String>,
//       (Get.find<DataService>().transBox.getValues() as Iterable<dynamic>).map(
//           (e) => (e as Map<String, dynamic>)
//               .map((key, value) => MapEntry(key, value as String))));
//   String get dTrans => _trans[LOCALEKEY]![this] ?? "";
// }
