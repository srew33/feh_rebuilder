import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/data_table.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as p;
import 'package:pointycastle/export.dart'
    hide Signer
    hide RSASigner
    hide Padding;

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
    String? ascendedAsset,
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
    }
    if (ascendedAsset != null) {
      assert(ascendedAsset != advantage);
      base_stats[ascendedAsset] = base_stats[ascendedAsset]! + 1;
      growth_rates[ascendedAsset] = growth_rates[ascendedAsset]! + 5;
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

    // 获得降序后的属性字典，数值相同时key按key列表的升序
    // 这里假定了base_stats一定是按顺序排列的
    var sortedStats = base_stats.entries.toList();
    sortedStats.sort((a, b) {
      return a.value != b.value ? b.value.compareTo(a.value) : -1;
    });

    // 计算X星属性逻辑为以3星为基础，1/5星直接-1/+1
    // 4星在3星基础上取除了hp外最高的两个+1，
    // 2星在3星基础上将HP和最低的两项-1
    switch (rarity) {
      case 1:
        deltaStats.updateAll((key, value) => value - 1);
        break;
      case 2:
        // HP及最低的两项-1
        deltaStats.update("hp", (value) => value - 1);
        int flag = 0;
        for (var entry in sortedStats.reversed) {
          if (entry.key != "hp") {
            deltaStats.update(entry.key, (value) => value - 1);
            flag++;
          }
          if (flag >= 2) {
            break;
          }
        }
        break;
      case 3:
        break;
      case 4:
        //  取除了hp外最高的两个+1
        int flag = 0;
        for (var entry in sortedStats) {
          if (entry.key != "hp") {
            deltaStats.update(entry.key, (value) => value + 1);
            flag++;
          }
          if (flag >= 2) {
            break;
          }
        }
        break;
      case 5:
        deltaStats.updateAll((key, value) => value + 1);
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
    // 按照降序的属性列表按顺序+1
    // 计算+1到+4,大于5的部分下面计算
    if (dragonflowers > 0) {
      for (var i = 0; i < dragonflowers % 5; i++) {
        deltaStats.update(sortedStats[i].key, (value) => value + 1);
      }
    }

    // 如果dragonflowers大于等于5， 每+5则五维再+1
    if (dragonflowers >= 5) {
      deltaStats.updateAll(
          (key, value) => value + 1 * (dragonflowers / 5).truncate());
    }
    // --------------------------------------------------召唤师的羁绊-----------------------
    // HP+5 四维+2
    if (summonerSupport) {
      deltaStats.updateAll((key, value) => key == "hp" ? value + 5 : value + 2);
    }
    // --------------------------------------------------神装英雄-----------------------
    // 五维+2
    if (resplendent) {
      deltaStats.updateAll((key, value) => value + 2);
    }

    //--------------------------------------------------突破---------------------------

    // 如果中性，前三高属性+1,有优劣属性 突破+1时劣势属性+3或+4
    if (merged > 0) {
      if (advantage == null && disadvantage == null) {
        // 中性，去除掉开花属性
        var withoutAscendedAsset = sortedStats.map((e) => e.key).toList();
        withoutAscendedAsset.removeWhere((element) => element == ascendedAsset);
        for (var i = 0; i < 3; i++) {
          deltaStats.update(withoutAscendedAsset[i], (value) => value + 1);
        }
      } else {
        assert(advantage != disadvantage);
        deltaStats[disadvantage!] =
            disAdvantageList.contains(growth_rates[disadvantage]! + 5)
                ? deltaStats[disadvantage]! + 4
                : deltaStats[disadvantage]! + 3;
      }
    }
    // 从+1到+5循环,大于5的部分下面计算
    for (int i = 0; i < merged % 5; i++) {
      deltaStats.update(sortedStats[(i * 2) % 5].key, (value) => value + 1);
      deltaStats.update(sortedStats[(i * 2 + 1) % 5].key, (value) => value + 1);
    }

    // 如果突破大于等于5， 每+5则五维再+2
    if (merged >= 5) {
      deltaStats.updateAll((key, value) => value + 2 * (merged / 5).truncate());
    }
    // 测试用
    if (kDebugMode) {
      Map mergedStats = Map.from(base_stats);
      mergedStats.forEach((key, value) {
        mergedStats[key] = mergedStats[key] + deltaStats[key];
      });
      // print("$rarity星1级突破$merged次神龙之花0次属性为：$mergedStats");
    }
    // -----------------------------------绽放个性------------------------------
    // int ascendedStats = 0;

    // if (ascendedAsset != null) {
    //   assert(ascendedAsset != advantage && statKeys.contains(ascendedAsset));
    //   // base_stats[ascendedAsset] = base_stats[ascendedAsset]! + 1;
    //   ascendedStats = advantageList.contains(growth_rates[ascendedAsset]!) ||
    //           (disAdvantageList.contains(growth_rates[ascendedAsset]! + 5) &&
    //               disadvantage == ascendedAsset)
    //       ? 4
    //       : 3;
    //   print(ascendedStats);
    // }

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

    // if (ascendedStats != 0) {
    //   // 中性且突破大于0时检查选择的开花个性是不是在排序后属性的前三个，是的话给所选属性补2，第四个属性补1，
    //   if (sortedStats.keys.toList().sublist(0, 3).contains(ascendedAsset) &&
    //       advantage == null &&
    //       disadvantage == null &&
    //       merged > 0) {
    //     result[ascendedAsset!] = result[ascendedAsset]! + ascendedStats - 1;
    //     result[sortedStats.keys.toList()[3]] =
    //         result[sortedStats.keys.toList()[3]]! + 1;
    //   } else {
    //     result[ascendedAsset!] = result[ascendedAsset]! + ascendedStats;
    //   }
    // }
    // 测试用
    // if (kDebugMode) {
    // print("""$rarity星$newLevel级突破$merged次
    //     神龙之花$dragonflowers次优势属性$advantage劣势属性$disadvantage
    //     属性为：$result""");
    // }

    return result;
  }

  // 降序排列属性值，数值相同时key按key列表的升序
  // static Map<String, int> _sortStats(Map<String, int> stats) {
  // List<String> _result = [];
  // List<String> keys = List.from(stats.keys);

  // List<int> values = List.from(stats.values);

  // // 降序排列
  // values.sort((int a, int b) => b.compareTo(a));

  // values.asMap().forEach((index, value) {
  //   // 按 "hp","atk","spd", "def","res"顺序得到第一个等于value的键名，然后加入结果中，最后删除
  //   // 这个键，以免在有几个属性重复时得到同一个键名
  //   String _key = keys.firstWhere((key) => stats[key] == value);
  //   _result.add(_key);
  //   keys.remove(_key);
  // });
  // return Map.fromIterables(_result, values);
  // }

  ///通过传入的skillTag搜索所有相关的专武1
  ///
  ///返回值：{专武Skill：专武效果Skill}
  static Map<Skill, Skill?> getCanRefineWeapons(
      String skillTag, Repository repo) {
    Map<Skill, Skill?> result = {};

    Skill exclusiveWeapon = repo.cacheSkills[skillTag]!;
    // Skill.fromJson(await repo.get(repo.skill, skillTag) ?? {});
    // 加入自身
    result.addAll({exclusiveWeapon: null});

    for (var s in repo.cacheSkills.values) {
      if (s.origSkill == exclusiveWeapon.idTag) {
        if (s.refineId != null) {
          result.addAll({s: repo.cacheSkills[s.refineId]});
        } else {
          // 如果武器未被锻造，一般指第二把专武
          result.addAll(getCanRefineWeapons(s.idTag!, repo));
        }
      }
    }

    return result;
  }

  static String getAssetsPath(String path) {
    // web下的测试地址不需要"assets"，其他环境需要"assets"
    if (kIsWeb && !kReleaseMode) {
      if (path.startsWith("assets")) {
        path = path.substring(7);
      }
    } else {
      if (!path.startsWith("assets")) {
        path = p.join("assets", path);
      }
    }
    return path.replaceAll(r"\", "/");
  }

  static void debug(Object o) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print(o);
    }
  }

  static Future<bool> verifySignature(
    Uint8List data,
    Uint8List signature,
  ) async {
    String hash = md5.convert(data).toString();

    final publicKeyString = await rootBundle.loadString('assets/update.pub');

    RSAKeyParser parser = RSAKeyParser();

    final signer2 = Signer(RSASigner(RSASignDigest.SHA256,
        publicKey: parser.parse(publicKeyString) as RSAPublicKey));

    return signer2.verify(hash, Encrypted(signature));
  }

  static void showToast(String info) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.dark
      ..maskType = EasyLoadingMaskType.none
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..radius = 20;
    EasyLoading.showToast(info);
  }

  static void showLoading([String? info]) {
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.ring;
    EasyLoading.show(status: info ?? '加载中...');
  }

  static Future<String> getChecksum(String path) async {
    File target = File(path);
    return await target.exists()
        ? sha1.convert(await target.readAsBytes()).toString()
        : "";
  }

  static Future<void> restoreOldVersionFavs(
      FavouritesTable favouritesTable) async {
    File target =
        File(p.join(EnvProvider.rootDir, "dataBox", "custom", "custom.gs"));
    if (await target.exists()) {
      Map<String, dynamic> data = jsonDecode(await target.readAsString());
      List<Map<String, dynamic>> favourites =
          (data["favorites"] as List).cast<Map<String, dynamic>>();
      Iterable<PersonBuild> transformed =
          favourites.map((e) => PersonBuild.fromJson(e));
      await favouritesTable.addAll(
          transformed.map((e) => e.timeStamp.toString()), favourites);
      debug("恢复成功");
    }
  }
}
