import 'package:feh_tool/dataService.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

///文件里面对应关系如下：
///人物名称:MPID
class Translation extends Translations {
  GetStorage trans = Get.find<DataService>().transBox;

  @override
  Map<String, Map<String, String>> get keys => Map.fromIterables(
      trans.getKeys() as Iterable<String>,
      (trans.getValues() as Iterable<dynamic>).map((e) =>
          (e as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as String))));
}
