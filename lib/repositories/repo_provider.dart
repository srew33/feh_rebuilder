import 'dart:convert';
import 'dart:io' show File;

import 'package:archive/archive.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'data_provider.dart';

final repoProvider = FutureProvider<Repository>((ref) async {
  Repository repo = await loadRepo();

  if (repo.gameDb.isFirstInitial) {
    // 尝试恢复老版本收藏数据
    await Utils.restoreOldVersionFavs(repo.favourites);
  }

  Config initialConfig = Config.fromJson(await repo.config.getAll());

  ref.read(configProvider.notifier).update((state) => initialConfig);

  My18nData.transDict =
      await repo.loadTranslationData(initialConfig.dataLanguage.locale);

  return repo;
});

Future<GameDb> loadDb() async {
  GameDb gameDb = await GameDb(p.join(EnvProvider.rootDir, "feh.db")).init();
  if (gameDb.db.version < EnvProvider.builtinDbVersion) {
    Utils.debug(
        "发现新版本 ${gameDb.db.version} -> ${EnvProvider.builtinDbVersion}");
    // 如果为真，表明是全新或更新安装
    if (EnvProvider.platformType == PlatformType.Android) {
      if (gameDb.db.version == 1) {
        Utils.debug("检测到首次启动");
        gameDb.isFirstInitial = true;
      }
      // 安卓环境，需要释放资源文件
      // windows自行解压
      var assets = await rootBundle.loadString("AssetManifest.json");

      Map<String, dynamic> d = jsonDecode(assets);

      for (var fileName in d.keys) {
        if (fileName.startsWith("assets")) {
          File f = File(p.join(EnvProvider.rootDir, fileName));
          await f.create(recursive: true);
          ByteData data = await rootBundle.load(fileName);
          await f.writeAsBytes(data.buffer.asUint8List());
        }
      }
      Utils.debug("释放资源文件完成");
    }

    Uint8List undecoded = kIsWeb
        ? (await rootBundle.load("assets/data.bin")).buffer.asUint8List()
        : await File(p.join(EnvProvider.rootDir, "assets", "data.bin"))
            .readAsBytes();

    final bytes = const ZLibDecoder().decodeBytes(undecoded);

    var data = jsonDecode(utf8.decode(bytes));

    await gameDb.updateDb(data);
  }
  return gameDb;
}

Future<Repository> loadRepo() async {
  GameDb gameDb = await loadDb();
  UserDb userDb = await UserDb(p.join(EnvProvider.rootDir, "user.db")).init();
  Repository repo = Repository(
    gameDb: gameDb,
    userDb: userDb,
  );
  await repo.initCaches();

  return repo;
}
