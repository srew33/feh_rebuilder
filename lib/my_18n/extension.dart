import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:sprintf/sprintf.dart';

extension Localization on String {
  String get tr {
    try {
      return (My18nData.transDict[this] ?? this);
    } on Exception {
      return "";
    }
  }

  String fill(List<Object> params) => sprintf(this, params);
}
