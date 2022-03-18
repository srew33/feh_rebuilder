import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:sprintf/sprintf.dart';

extension Localization on String {
  String get tr {
    try {
      return (Repository.translationData[this] ?? this);
    } on Exception {
      return "";
    }
  }

  String fill(List<Object> params) => sprintf(this, params);
}
