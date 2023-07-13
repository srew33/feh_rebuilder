import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast.dart';

import 'package:sembast/utils/sembast_import_export.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite;

/// 数据层
abstract class DataProvider {
  final String dbPath;

  DatabaseFactory dbFactory = kIsWeb
      ? databaseFactoryWeb
      : getDatabaseFactorySqflite(sqflite.databaseFactoryFfi);

  late Database db;

  DataProvider(this.dbPath);

  Future init();
}

/// 游戏资料库
class GameDb extends DataProvider {
  GameDb(String dbPath) : super(dbPath);

  /// 是否首次加载,为真则尝试加载老版本收藏数据
  bool isFirstInitial = false;

  @override
  Future<GameDb> init() async {
    // 减少内存消耗 400+MB -> 200+MB
    if (!kIsWeb) {
      dbFactory.sqfliteImportPageSize = 100;
    }
    db = await dbFactory.openDatabase(
      p.join(EnvProvider.rootDir, dbPath).replaceAll(r"\", "/"),
    );

    return this;
  }

  Future<void> initialDb(Map<String, dynamic> data) async {
    await db.close();
    Utils.debug("关闭完成");

    db = await importDatabase(data, dbFactory, dbPath);

    Utils.debug("升级完成");
  }

  Future<void> updateDb(Map<String, dynamic> data) async {
    await db.close();
    Utils.debug("关闭完成");
    //  需要先关闭才能使用，否则不会报错也无法继续
    // ! 更新后有一些操作可能会因为db实例发生变化导致报错

    if (EnvProvider.appVersionCode < (data["minimal_support_version"] ?? 999)) {
      throw UnsupportedError(
          "程序版本(${EnvProvider.appVersionCode})和更新包(${data["minimal_support_version"]})不匹配");
    }

    db = await importDatabase(data, dbFactory, dbPath);

    Utils.debug("升级完成");
  }
}

/// 用户数据库，包含系统配置和收藏
class UserDb extends DataProvider {
  UserDb(String dbPath) : super(dbPath);

  @override
  Future<UserDb> init() async {
    db = await dbFactory.openDatabase(
      p.join(EnvProvider.rootDir, dbPath).replaceAll(r"\", "/"),
    );

    return this;
  }
}
