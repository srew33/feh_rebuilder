import 'dart:io';

import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 静态类，根据系统不同提供一些全局的变量和服务初始化
class EnvProvider {
  ///当前系统类型
  static late final PlatformType platformType;

  /// 当前程序根路径
  static late final String rootDir;

  /// 临时/缓存路径
  static late final String tempDir;

  /// 程序版本
  static const String appVersion = "1.2.1";

  /// 内建数据版本,必须与data.bin保持一致
  static const int builtinDbVersion = 1649208732256;

  /// app版本
  static const int appVersionCode = 15;

  static Future<void> init() async {
    platformType = PlatformInfo().getCurrentPlatformType();

    switch (platformType) {
      case PlatformType.Android:
        rootDir = (await getApplicationDocumentsDirectory()).absolute.path;
        tempDir = (await getTemporaryDirectory()).absolute.path;
        break;
      case PlatformType.Windows:
        rootDir = Directory.current.absolute.path;
        tempDir = p.join(rootDir, "cache");
        break;
      case PlatformType.Web:
        rootDir = "";
        tempDir = "";
        break;
      default:
        throw UnsupportedError("暂不支持该平台");
    }
  }
}
