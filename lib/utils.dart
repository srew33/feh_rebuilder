import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hashids2/hashids2.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;

import 'package:pointycastle/export.dart'
    hide Signer
    hide RSASigner
    hide Padding;

import 'package:feh_rebuilder/models/person/person.dart';

import 'package:feh_rebuilder/models/skill/skill.dart';

import 'package:flutter/foundation.dart';

import 'package:get_storage/get_storage.dart';

class Utils {
  static const List<String> statKeys = [
    "hp",
    "atk",
    "spd",
    "def",
    "res",
  ];
  // 优势/劣势属性的对应成长值，可以通过计算
  //int growValue = ((40 - 1) * (growth_rates[statKey]! * (0.79 + (0.07 * 5))).truncate() /100).truncate();
  // 的差值得到，注意差值为3点的实际为4点（优劣势属性在计算1级真实属性时会+/-1点），这里
  // 为了简便直接给出计算得出的列表，通过查表可以得知某属性是否优势/劣势
  static const List<int> advantageList = [25, 45, 70, 90];
  static const List<int> disAdvantageList = [10, 30, 50, 75, 95];

  ///计算给定条件的角色属性，返回的结果是不装备武器的基础值
  ///
  ///[person]必须，角色模型
  ///
  ///[oldLevel]必须，初始等级，一般来说应该为1
  ///
  ///[newLevel]必须，需要计算的等级，一般来说应该为40
  ///
  ///[rarity]必须，稀有度
  ///
  ///[advantage]可选，优势属性
  ///
  ///[disadvantage]可选，劣势属性
  ///
  ///[merged]可选，突破次数
  ///
  ///[dragonflowers]可选，神龙之花次数
  ///
  ///[resplendent]可选，是否神装英雄
  ///
  ///[summonerSupport]可选，是否召唤师羁绊
  ///
  static Map<String, int> calcStats(
    Person person,
    int oldLevel,
    int newLevel,
    int rarity, [
    String? advantage,
    String? disadvantage,
    int merged = 0,
    int dragonflowers = 0,
    bool resplendent = false,
    bool summonerSupport = false,
  ]) {
    // ignore: non_constant_identifier_names
    Map<String, int> base_stats = person.baseStats!.toJson();
    // ignore: non_constant_identifier_names
    Map<String, int> growth_rates = person.growthRates!.toJson();
    // 计算三星时真实属性，采用异或运算判断优势和劣势性格是否全为null或全有值
    // 如果存在优劣性格，那么三星一级时优势性格属性+1，成长率+5，劣势性格相反
    // 计算神龙之花和突破时似乎是以真实属性即算入优劣属性后的数值计算
    if (!((advantage == null) ^ (disadvantage == null))) {
      if (statKeys.contains(advantage) && statKeys.contains(disadvantage)) {
        base_stats[advantage!] = base_stats[advantage]! + 1;
        base_stats[disadvantage!] = base_stats[disadvantage]! - 1;
        growth_rates[advantage] = growth_rates[advantage]! + 5;
        growth_rates[disadvantage] = growth_rates[disadvantage]! - 5;
      }
    } else {
      throw "calcStats 性格传入错误";
    }
    if (kDebugMode) {
      // print("真实三星属性为：$base_stats");
    }

    // ---------------------------------------觉醒------------------------------
    // 计算觉醒后属性，虽然没有1，2星了，姑且还是加上
    // 计算一星时真实属性，直接五维减一
    // 属性总变动字典，最后计算时与初始属性相加
    Map<String, int> deltaStats = {
      "hp": 0,
      "atk": 0,
      "spd": 0,
      "def": 0,
      "res": 0,
    };

    // 计算X星属性逻辑为以3星为基础，1/5星直接-1/+1，2/4星在1/3星基础上取最大的前两个数值+1，
    // 获得降序后的属性字典，如果多个属性相同，取key顺序在前的+1
    Map<String, int> sortedStats = _sortStats(base_stats);

    switch (rarity) {
      case 1:
        deltaStats.forEach((key, value) {
          deltaStats[key] = deltaStats[key]! - 1;
        });
        break;
      case 2:
        base_stats.forEach((key, value) {
          deltaStats[key] = deltaStats[key]! - 1;
        });
        Map<String, int> _ = Map.from(sortedStats);
        //  取除了hp外最高的两个+1
        _.remove("hp");
        for (int i = 0; i < 2; i++) {
          deltaStats[_.keys.elementAt(i)] =
              deltaStats[_.keys.elementAt(i)]! + 1;
        }
        break;
      case 3:
        break;
      case 4:
        Map<String, int> _ = Map.from(sortedStats);
        //  取除了hp外最高的两个+1
        _.remove("hp");
        for (int i = 0; i < 2; i++) {
          deltaStats[_.keys.elementAt(i)] =
              deltaStats[_.keys.elementAt(i)]! + 1;
        }
        break;
      case 5:
        deltaStats.forEach((key, value) {
          deltaStats[key] = deltaStats[key]! + 1;
        });
        break;
    }

// 测试用
    if (kDebugMode) {
      Map rarityStats = Map.from(base_stats);
      rarityStats.forEach((key, value) {
        rarityStats[key] = rarityStats[key] + deltaStats[key];
      });
      // print("$rarity星1级属性为：$rarityStats");
    }

    // --------------------------------------------------神龙之花-----------------------
    // 计算+1到+4,大于5的部分下面计算
    if (dragonflowers > 0) {
      for (var i = 0; i < dragonflowers % 5; i++) {
        deltaStats[sortedStats.keys.elementAt(i)] =
            deltaStats[sortedStats.keys.elementAt(i)]! + 1;
      }
    }

    // 如果dragonflowers大于等于5， 每+5则五维再+1
    if (dragonflowers >= 5) {
      deltaStats.forEach((key, value) {
        deltaStats[key] = deltaStats[key]! + 1 * (dragonflowers / 5).truncate();
      });
    }
    // --------------------------------------------------召唤师的羁绊-----------------------
    // HP+5 四维+2
    if (summonerSupport) {
      deltaStats.forEach((key, value) {
        if (key == "hp") {
          deltaStats[key] = deltaStats[key]! + 5;
        } else {
          deltaStats[key] = deltaStats[key]! + 2;
        }
      });
    }
    // --------------------------------------------------神装英雄-----------------------
    // 五维+2
    if (resplendent) {
      deltaStats.forEach((key, value) {
        deltaStats[key] = deltaStats[key]! + 2;
      });
    }

    //--------------------------------------------------突破---------------------------

    // 如果中性，前三高属性+1,有优劣属性 突破+1时劣势属性+3或+4
    if (merged > 0) {
      if (advantage == null && disadvantage == null) {
        // 中性
        for (int i = 0; i < 3; i++) {
          deltaStats[sortedStats.keys.elementAt(i)] =
              deltaStats[sortedStats.keys.elementAt(i)]! + 1;
        }
      } else if (advantage != disadvantage) {
        deltaStats[disadvantage!] =
            disAdvantageList.contains(growth_rates[disadvantage]! + 5)
                ? deltaStats[disadvantage]! + 4
                : deltaStats[disadvantage]! + 3;
      }
    }
    // 从+1到+5循环,大于5的部分下面计算
    for (int i = 0; i < merged % 5; i++) {
      List<int> toDo = [(i * 2) % 5, (i * 2 + 1) % 5];
      for (var index in toDo) {
        deltaStats[sortedStats.keys.elementAt(index)] =
            deltaStats[sortedStats.keys.elementAt(index)]! + 1;
      }
    }

    // 如果merge大于等于5， 每+5则五维再+2
    if (merged >= 5) {
      deltaStats.forEach((key, value) {
        deltaStats[key] = deltaStats[key]! + 2 * (merged / 5).truncate();
      });
    }
    // 测试用
    if (kDebugMode) {
      Map mergedStats = Map.from(base_stats);
      mergedStats.forEach((key, value) {
        mergedStats[key] = mergedStats[key] + deltaStats[key];
      });
      // print("$rarity星1级突破$merged次神龙之花0次属性为：$mergedStats");
    }

// ---------------------------------------计算最终数据-----------------------------
    Map<String, int> result = {};
    for (var statKey in statKeys) {
      // 该属性到指定等级的成长值
      int growValue = ((newLevel - oldLevel) *
              (growth_rates[statKey]! * (0.79 + (0.07 * rarity))).truncate() /
              100)
          .truncate();

      result[statKey] = base_stats[statKey]! + deltaStats[statKey]! + growValue;
    }
    // 测试用
    // if (kDebugMode) {
    // print("""$rarity星$newLevel级突破$merged次
    //     神龙之花$dragonflowers次优势属性$advantage劣势属性$disadvantage
    //     属性为：$result""");
    // }

    return result;
  }

  ///降序排列属性值，数值相同时key按key列表的升序
  static Map<String, int> _sortStats(Map<String, int> stats) {
    List<String> _result = [];
    List<String> keys = List.from(stats.keys);

    List<int> values = List.from(stats.values);

    // 降序排列
    values.sort((int a, int b) => b.compareTo(a));

    values.asMap().forEach((index, value) {
      // 按 "hp","atk","spd", "def","res"顺序得到第一个等于value的键名，然后加入结果中，最后删除
      // 这个键，以免在有几个属性重复时得到同一个键名
      String _key = keys.firstWhere((key) => stats[key] == value);
      _result.add(_key);
      keys.remove(_key);
    });
    return Map.fromIterables(_result, values);
  }

  ///通过传入的skillTag搜索所有相关的专武
  static List<Map<Skill, Skill>> getExclusive(
      String skillTag, GetStorage skillBox) {
    List<Map<Skill, Skill>> result = [];

    Skill exclusiveWeapon = Skill.fromJson(skillBox.read(skillTag));
    // print(exclusiveWeapon);
    if (exclusiveWeapon.refineList != null) {
      for (String exclusiveWeaponIdTAG in exclusiveWeapon.refineList!) {
        Skill w = Skill.fromJson(skillBox.read(exclusiveWeaponIdTAG));
        if (w.refineId != null && w.refined!) {
          // 第一把专武
          Skill effectIdTag = Skill.fromJson(skillBox.read(w.refineId!));
          result.add({w: effectIdTag});
        } else if (!w.refined!) {
          // 其他专武
          result.addAll(getExclusive(w.idTag!, skillBox));
        }
      }
    }
    // print(result);
    return result;
  }

  ///把bool，list，map等转换成json 存到数据库
  static Map<String, dynamic> map2Db(Map<String, dynamic> dict) {
    Map<String, dynamic> _dict = Map<String, dynamic>.from(dict);
    for (String k in _dict.keys) {
      if (_dict[k] is String || _dict[k] is num || _dict[k] is Uint8List) {
      } else {
        _dict[k] = jsonEncode(_dict[k]);
        // print("$k -> ${_dict[k]} ");
      }
    }
    // print("convert done");
    return _dict;
  }

  ///把JSON还原成bool，list，map等类型
  static Map<String, dynamic> db2Map(Map<String, dynamic> dict) {
    // 数据库结果是只读的
    Map<String, dynamic> _dict = Map<String, dynamic>.from(dict);
    for (String k in _dict.keys) {
      try {
        _dict[k] = jsonDecode(_dict[k]);
      } catch (e) {
        // 如果不是string类型，就不管
      }
    }
    // print("convert done");
    return _dict;
  }

  static void debug(Object o) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print(o);
    }
    // assert(() {
    //   print(o);
    //   return true;
    // }());
  }

  static Future<bool> verifySignature(String updateFilePath) async {
    final bytes = await File(updateFilePath).readAsBytes();
    if (bytes.length > 384) {
      Uint8List data = bytes.sublist(0, bytes.length - 384);
      Uint8List signature = bytes.sublist(bytes.length - 384, bytes.length);

      String md5Hash = md5.convert(data).toString();

      final publicKeyString = await rootBundle.loadString('assets/update.pub');

      RSAKeyParser parser = RSAKeyParser();

      final signer2 = Signer(RSASigner(RSASignDigest.SHA256,
          publicKey: parser.parse(publicKeyString) as RSAPublicKey));

      return signer2.verify(md5Hash, Encrypted(signature));
    } else {
      throw "错误的更新包";
    }
  }

  ///[String updateFile, Directory tempDir]
  ///验证签名后释放更新文件
  static bool unzipAssets(List args) {
    Uint8List data = File(args[0]).readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(data);

    for (final file in archive) {
      final filename = file.name;

      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(args[1].path, "update", filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Utils.debug(filename);
        Directory(p.join(args[1].path, "update", filename))
            .createSync(recursive: true);
      }
    }

    File(p.join(args[1].path, "update", "update.flag"))
        .createSync(recursive: true);

    return true;
  }

  ///启动时检查是否存在需要更新的assets，如果有就覆盖对应文件
  static Future<bool> updateAssets(List<Directory> args) async {
    Directory appPath = args[0];
    Directory tempDir = args[1];

    //如果temp目录下存在"update/toUpdate.flag",那么将update下的所有文件覆盖到数据目录下的assets
    if (await File(p.join(tempDir.path, "update", "update.flag")).exists()) {
      Utils.debug("开始覆盖数据文件");
      await for (FileSystemEntity fileSystemEntity
          in Directory(p.join(tempDir.path, "update")).list(recursive: true)) {
        if (fileSystemEntity is File) {
          String relative = p.relative(fileSystemEntity.path,
              from: p.join(tempDir.path, "update"));

          await fileSystemEntity
              .rename(p.join(appPath.path, "assets", relative));
        }
      }
      Utils.debug("更新完成");
    }

    return true;
  }

  /// 启动时检查缓存文件夹是否存在，如果存在就清空
  static Future<void> cleanCache(Directory tempDir) async {
    // Directory tempDir = GetPlatform.isMobile
    //     ? await getTemporaryDirectory()
    //     : Directory(r"H:\GitProject\flutter\feh_heroes\feh_rebuilder\cache");
    // 最后清空缓存文件夹，filepicker会将选择的文件缓存到这里影响下次更新，因此最好全部删除
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  /// 自定义build转字符串
  static String encodeBuild(
      PersonBuild build, List<Skill?> skills, Person person) {
    List<int> all = [];

    all.add(person.idNum!);
    all.add(
        build.advantage == null ? 9 : Utils.statKeys.indexOf(build.advantage!));
    all.add(build.disAdvantage == null
        ? 9
        : Utils.statKeys.indexOf(build.disAdvantage!));
    all.add(build.rarity);
    all.add(build.merged);
    all.add(build.dragonflowers);
    all.add(build.resplendent ? 1 : 0);
    all.add(build.summonerSupport ? 1 : 0);
    all.add(build.arenaScore);
    all.addAll([for (Skill? s in skills) s == null ? 0 : s.idNum!]);
    // HashIds主要实现多个int的合并编码和压缩，不需要加密，所以不用加盐
    String result = HashIds().encodeList(all);

    return result;
  }

  /// 字符串转自定义build
  static PersonBuild? decodeBuild(String encoded, DataService data) {
    List<int> all = HashIds().decode(encoded);
    PersonBuild? result;

    if (all.length != 17) {
      return result;
    }

    Iterable<Map<String, dynamic>> skills =
        (data.skillBox.getValues() as Iterable<dynamic>)
            .cast<Map<String, dynamic>>();

    String personTag = (data.personBox.getValues() as Iterable<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere((element) => element["id_num"] == all[0])["id_tag"];

    List<String?> skillsTags = [
      for (int idNum in all.sublist(9, 17))
        idNum == 0
            ? null
            : skills
                .firstWhere((element) => element["id_num"] == idNum)["id_tag"]
    ];
    result = PersonBuild(personTag: personTag, equipSkills: skillsTags)
      ..advantage = all[1] == 9 ? null : statKeys[all[1]]
      ..disAdvantage = all[2] == 9 ? null : statKeys[all[2]]
      ..rarity = all[3]
      ..merged = all[4]
      ..dragonflowers = all[5]
      ..resplendent = all[6] == 1 ? true : false
      ..summonerSupport = all[7] == 1 ? true : false
      ..arenaScore = all[8];

    return result;
  }

  static void showToast(String info) {
    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: info,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
