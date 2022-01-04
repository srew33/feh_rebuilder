import 'dart:io';
import 'dart:ui' show Locale;

import 'package:archive/archive.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

class DataService extends GetxService {
  late GetStorage transBox;
  late GetStorage personBox;
  late GetStorage skillBox;
  late GetStorage moveBox;
  late GetStorage skillAccessoryBox;
  late GetStorage weaponBox;
  late GetStorage weaponRefineBox;
  late GetStorage customBox;
  // late String appVersionAlias;
  late String appVersionAlias;
  late int appVersion;
  int get assetsVersion {
    return int.parse(customBox.read("dataVersion"));
  }

  Map<String, dynamic> defaultConfig = const {
    "initialed": false,
    "dataLanguage": "繁体中文",
    "currentVersion": "",
    "dataVersion": "0",
    "favorites": <PersonBuild>[],
  };

  Map<String, Locale> languageDict = const {
    "繁体中文": Locale("zh", "TW"),
    "日本語": Locale("ja", "JP"),
    "English": Locale("en", "US"),
  };

  bool isInitialed(String version) {
    if (!customBox.read("initialed")) {
      Utils.debug("首次启动");
      return false;
    } else if (customBox.read("currentVersion") != version) {
      Utils.debug("更新启动");
      customBox.write("currentVersion", version);
      return false;
    }
    Utils.debug("正常启动");
    return true;
  }

  Directory appPath;
  Directory tempDir;

  DataService({required this.appPath, required this.tempDir});

  Future<void> releaseData() async {
    ByteData data = await rootBundle.load("assets/assets.zip");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File f = File(p.join(appPath.path, "assets", filename));
        await f.create(recursive: true);
        await f.writeAsBytes(data);
      } else {
        await Directory(p.join(appPath.path, "assets", filename))
            .create(recursive: true);
      }
    }

    customBox.write("initialed", true);
  }

  Future<DataService> init() async {
    /// 检测启动环境是否是web，并加载相应服务（web环境数据由后端服务提供，本地环境由本地数据库或json提供）

    Utils.debug("init dataService");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersionAlias = packageInfo.version;

    // assetsVersion =
    Utils.debug(appVersionAlias);

    if (GetPlatform.isWeb) {
      Utils.debug("web");
    } else if (GetPlatform.isMobile) {
      appVersion = int.parse(packageInfo.buildNumber);
      await initMobile();
    } else if (GetPlatform.isDesktop) {
      appVersion = 13;
      await initDesktop();
    } else {
      throw "未知平台";
    }

    return this;
  }

  Future<void> initMobile() async {
    customBox = GetStorage('custom', p.join(appPath.path, "dataBox", "custom"));
    await GetStorage.init("custom");

    // customBox完全为空,代表首次启动
    if ((customBox.getKeys() as Iterable<dynamic>).isEmpty) {
      defaultConfig.forEach((key, value) {
        customBox.write(key, value);
      });
    }

    Utils.debug("当前app版本：$appVersionAlias");
    // 首次启动或更新软件版本启动
    bool initialed = isInitialed(appVersionAlias);
    if (!initialed) {
      await releaseData();
      customBox.write("currentVersion", appVersionAlias);
      // 把data.version里的时间戳写入customBox
    }
    // 检测数据版本是否变化并写入,update.flag存在时代表更新了数据版本，initialed为false表示更新了程序版本
    File f1 = File(p.join(appPath.path, "assets", "update.flag"));
    File f2 = File(p.join(appPath.path, "assets", "data.version"));
    if (!initialed) {
      customBox.write("dataVersion", await File(f2.path).readAsString());
    }
    if (await f1.exists()) {
      customBox.write("dataVersion", await File(f2.path).readAsString());
      await f1.delete();
    }

// 只使用到了transBox，personBox，skillBox，weaponBox
    transBox = GetStorage('translations',
        p.join(appPath.path, "assets", "dataBox", "translations"));
    await GetStorage.init("translations");

    personBox = GetStorage(
        'personBox', p.join(appPath.path, "assets", "dataBox", "personBox"));
    await GetStorage.init("personBox");

    skillBox = GetStorage(
        'skillBox', p.join(appPath.path, "assets", "dataBox", "skillBox"));
    await GetStorage.init("skillBox");

    skillAccessoryBox = GetStorage('skillAccessoryBox',
        p.join(appPath.path, "assets", "dataBox", "skillAccessoryBox"));
    await GetStorage.init("skillAccessoryBox");

    weaponBox = GetStorage(
        'weaponBox', p.join(appPath.path, "assets", "dataBox", "weaponBox"));
    await GetStorage.init("weaponBox");

    weaponRefineBox = GetStorage('weaponRefineBox',
        p.join(appPath.path, "assets", "dataBox", "weaponRefineBox"));
    await GetStorage.init("weaponRefineBox");

    moveBox = GetStorage(
        'moveBox', p.join(appPath.path, "assets", "dataBox", "moveBox"));
    await GetStorage.init("moveBox");
  }

  Future<void> initDesktop() async {
    Utils.debug("init desktop");

    customBox = GetStorage(
        'custom', p.join(appPath.path, "assets", "dataBox", "custom"));
    await GetStorage.init("custom");

    if ((customBox.getKeys() as Iterable<dynamic>).isEmpty) {
      defaultConfig.forEach((key, value) {
        customBox.write(key, value);
      });
    }

    transBox = GetStorage('translations', r"assets\dataBox\translations");
    await GetStorage.init("translations");

    personBox = GetStorage('personBox', r"assets\dataBox\personBox");
    await GetStorage.init("personBox");

    skillBox = GetStorage('skillBox', r"assets\dataBox\skillBox");
    await GetStorage.init("skillBox");

    skillAccessoryBox =
        GetStorage('skillAccessoryBox', r"assets\dataBox\skillAccessoryBox");
    await GetStorage.init("skillAccessoryBox");

    weaponBox = GetStorage('weaponBox', r"assets\dataBox\weaponBox");
    await GetStorage.init("weaponBox");

    weaponRefineBox =
        GetStorage('weaponRefineBox', r"assets\dataBox\weaponRefineBox");
    await GetStorage.init("weaponRefineBox");

    moveBox = GetStorage('moveBox', r"assets\dataBox\moveBox");
    await GetStorage.init("moveBox");
  }
}
