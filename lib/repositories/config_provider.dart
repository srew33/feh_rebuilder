import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final configProvider = StateProvider<Config>((ref) {
  return const Config();
});

class Config extends Equatable {
  const Config({
    this.initialed = false,
    this.allowGetSysId = false,
    this.dataLanguage = AppLanguages.zh,
    this.allowCustomGameDB = false,
    this.webServiceId = "",
  });

  /// 程序是否已初始化，默认false
  final bool initialed;

  /// 允许获取系统ID开关，默认false
  final bool allowGetSysId;

  /// 数据显示的语言，默认为繁体中文
  final AppLanguages dataLanguage;

  //是否忽略签名，默认false
  final bool allowCustomGameDB;

  //当前网络服务的唯一ID
  final String webServiceId;

  Config copyWith({
    bool? initialed,
    bool? allowGetSysId,
    AppLanguages? dataLanguage,
    bool? allowCustomGameDB,
    String? webServiceId,
  }) {
    return Config(
      initialed: initialed ?? this.initialed,
      allowGetSysId: allowGetSysId ?? this.allowGetSysId,
      dataLanguage: dataLanguage ?? this.dataLanguage,
      allowCustomGameDB: allowCustomGameDB ?? this.allowCustomGameDB,
      webServiceId: webServiceId ?? this.webServiceId,
    );
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      initialed: json["initialed"] ?? false,
      allowGetSysId: json["allowGetSysId"] ?? false,
      allowCustomGameDB: json["allowCustomGameDB"] ?? false,
      dataLanguage: AppLanguages.values[json["dataLang"] ?? 0],
      webServiceId: json["webServiceId"] ?? "",
    );
  }

  @override
  List<Object> get props =>
      [initialed, allowGetSysId, dataLanguage, allowCustomGameDB, webServiceId];
}
