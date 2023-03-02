import 'dart:async';
import 'dart:convert';
import 'dart:math' as m;
import 'dart:ui';

import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/data_table.dart';
import 'package:feh_rebuilder/utils.dart';

import 'data_provider.dart';

enum DataTypeEnum { person, skill, weapon, favourites, arenaTeam, config }

extension MapUtils<K, V> on Map<K, V> {
  Future<V> putIfAbsentAsync(K key, FutureOr<V> Function() action) async {
    final V? previous = this[key];
    final V current;
    if (previous == null) {
      current = await action();
      this[key] = current;
    } else {
      current = previous;
    }
    return current;
  }
}

/// 数据服务
class Repository implements TranslationLoader {
  GameDb gameDb;
  UserDb userDb;

  Repository({
    required this.gameDb,
    required this.userDb,
  }) {
    person = PersonTable(db: gameDb.db);
    skill = SkillTable(db: gameDb.db);
    weapon = WeaponTable(db: gameDb.db);
    translations = TranslationsTable(db: gameDb.db);
    favourites = FavouritesTable(db: userDb.db);
    arenaTeam = ArenaTeamTable(db: userDb.db);
    config = ConfigTable(db: userDb.db);
  }

  late final PersonTable person;
  late final SkillTable skill;
  late final WeaponTable weapon;
  late final TranslationsTable translations;
  late final FavouritesTable favourites;
  late final ArenaTeamTable arenaTeam;
  late final ConfigTable config;

  /// 目前在启动时会存储所有数据，如果内存占用过大改为缓存形式
  Map<String, WeaponType> cacheWeaponTypes = {};
  Map<String, Person> cachePersons = {};
  Map<String, Skill> cacheSkills = {};
  Map<String, PersonBuild> cacheFavHero = {};
  Map<String, List<String?>> cacheArenateam = {};

  String get appPath => EnvProvider.rootDir;

  int get version => gameDb.db.version;

  FutureOr readOne(DataTypeEnum type, String key) async {
    switch (type) {
      case DataTypeEnum.person:
        return cachePersons.putIfAbsentAsync(
            key, () async => Person.fromJson((await person.read(key))!));
      case DataTypeEnum.skill:
        return cacheSkills.putIfAbsentAsync(
            key, () async => Skill.fromJson((await skill.read(key))!));
      case DataTypeEnum.weapon:
        return cacheWeaponTypes.putIfAbsentAsync(
            key, () async => WeaponType.fromJson((await weapon.read(key))!));

      case DataTypeEnum.favourites:
        return cacheFavHero.putIfAbsentAsync(
            key,
            () async =>
                PersonBuild.fromJson(key, (await favourites.read(key))!));

      case DataTypeEnum.arenaTeam:
        return cacheArenateam.putIfAbsentAsync(
            key, () async => (await arenaTeam.read(key)));

      case DataTypeEnum.config:
        return Config.fromJson(await config.getAll());
      default:
        throw UnimplementedError();
    }
  }

  FutureOr<Iterable> readSome(DataTypeEnum type, List<String> keys) async {
    return keys.map((key) async => await readOne(type, key));
  }

  Future readAll(DataTypeEnum type) async {
    switch (type) {
      case DataTypeEnum.person:
        return (await person.getAll())
            .map((key, value) => MapEntry(key, Person.fromJson(value)));
      case DataTypeEnum.skill:
        return (await skill.getAll())
            .map((key, value) => MapEntry(key, Skill.fromJson(value)));
      case DataTypeEnum.weapon:
        return (await weapon.getAll())
            .map((key, value) => MapEntry(key, WeaponType.fromJson(value)));

      case DataTypeEnum.favourites:
        return (await favourites.getAll()).map(
            (key, value) => MapEntry(key, PersonBuild.fromJson(key, value)));

      case DataTypeEnum.arenaTeam:
        return (await arenaTeam.getAll()).map(
            (key, value) => MapEntry(key, (value as List).cast<String?>()));

      default:
        throw UnimplementedError();
    }
  }

  Future<void> initCaches() async {
    cacheWeaponTypes = (await weapon.getAll())
        .map((key, value) => MapEntry(key, WeaponType.fromJson(value)));

    cachePersons = (await person.getAll())
        .map((key, value) => MapEntry(key, Person.fromJson(value)));

    cacheSkills = (await skill.getAll())
        .map((key, value) => MapEntry(key, Skill.fromJson(value)));

    cacheFavHero = (await favourites.getAll())
        .map((key, value) => MapEntry(key, PersonBuild.fromJson(key, value)));

    cacheArenateam = (await arenaTeam.getAll())
        .map((key, value) => MapEntry(key, (value as List).cast<String?>()));

    await _cleanAreana();
  }

  Future<String> getRestoreData() async {
    await _cleanAreana();
    var allF = await favourites.getAll();
    var allA = await arenaTeam.getAll();

    if (allF.isEmpty && allA.isEmpty) {
      return "";
    }

    Map all = {};
    all["favourites"] = allF;
    all["arena"] = allA;
    all["restore_version"] = 140;

    return base64Encode(utf8.encode(jsonEncode(all)));
  }

  /// 清理竞技场表的脏数据
  Future<void> _cleanAreana() async {
    List<String> toDel = [];
    for (var e in cacheArenateam.entries) {
      // if (!e.value.any((element) => element != null)) {
      //   toDel.add(e.key);
      // }
      bool toDelFlag = true;
      for (var tag in e.value) {
        if (tag != null) {
          var t = await favourites.read(tag);
          if (t != null) {
            toDelFlag = false;
            break;
          }
        }
      }

      if (toDelFlag) {
        toDel.add(e.key);
      }
    }
    await arenaTeam.deleteSome(toDel);
  }

  Future<Map<String, String>> loadTranslationData(Locale newLocale) async {
    return (await translations.read(newLocale.languageCode) ?? {})
        .map((key, value) => MapEntry(key, value as String? ?? ""));
  }

  List<Skill?> getSkillsByTags(List<String?> tags) {
    List<Skill?> result =
        tags.map((e) => e == null ? null : cacheSkills[e]).toList();

    return result;
  }

  /// 通过传入的人物模型获取该人物初始化技能
  ///
  /// 顺序为武器、辅助、奥义、A、B、C、S、祝福、需学习的专武
  List<Skill?> getPersonInitialSkills(Person hero) {
    // 将二维skills降维,获得一维的技能列表
    List<String?> all =
        hero.skills!.skills.fold<List<String?>>([], (previousValue, element) {
      previousValue.addAll(element);
      return previousValue;
    });

    // 将人物所有技能替换成skill模型
    List<Skill?> skills =
        all.map((e) => e == null ? null : cacheSkills[e]).toList();

    // 初始化返回的技能列表，最后一位是可学习的专武
    // 顺序为武器、辅助、奥义、A、B、C、S、祝福、需学习的专武
    List<Skill?> s = List.filled(9, null);
    // 循环根据category替换技能列表
    skills.asMap().forEach((index, skill) {
      // 技能为恒定的70个，每14个技能为一组
      index = index % 14;
      if (skill != null) {
        // 如果是专武并且索引大于5，表示是需要学习后装备的武器
        if (skill.exclusive! && skill.category! == 0 && index > 5) {
          s[8] = skill;
        } else {
          // 如果_skills的category位不为空则比较技能级别，否则直接替换
          if (s[skill.category!] != null) {
            s[skill.category!] = _compareSkill(s[skill.category!], skill);
          } else {
            s[skill.category!] = skill;
          }
        }
      }
    });
    // 对于一些真五杖系英雄，五星时武器位是null，专武会装备在后面，因此显示的是低级武器
    // 低级武器一般是袭击SID_アサルト,这里通过技能spcost判断，除袭击外最低级的技能都会>=150
    // 如果满足条件则把专武位的技能放到武器位上
    if (s[0] != null && (s[0]?.spCost ?? 0) < 100) {
      s[0] = s[8];
    }
    return s;
  }

  /// 比较两个技能上下级关系，如果S1的前置技能有S2则返回S1，否则返回S2，
  Skill? _compareSkill(Skill? s1, Skill? s2) {
    if (s1 == null && s2 == null) {
      return null;
    } else if (s1 == null || s2 == null) {
      return s1 ?? s2;
    } else {
      return s1.prerequisites.contains(s2.idTag) ? s1 : s2;
    }
  }

  Future<void> restoreFavourites(String source) async {
    if (source.isEmpty) {
      return;
    }

    try {
      Map<String, Map<String, dynamic>> data;
      var json = jsonDecode(utf8.decode(base64Decode(source)));
      if (json is Map) {
        if (!json.containsKey("restore_version")) {
          await _restore130(json as Map<String, dynamic>);
        } else if (json["restore_version"] == 140) {
          await _restore140(json as Map<String, dynamic>);
        }
      } else if (json is List) {
        data = Map.fromEntries(json
            .cast<Map<String, dynamic>>()
            .map((e) => MapEntry(e["time_stamp"].toString(), e)));
        await favourites.addAll(data.keys, data.values.toList());
      } else {
        throw "数据错误";
      }

      Utils.showToast("恢复成功,请重启软件");
    } on Exception catch (e) {
      Utils.debug(e.toString());
      Utils.showToast("恢复失败");
    }
  }

  Future _restore130(Map<String, dynamic> json) async {
    Map<String, Map<String, dynamic>> data =
        json.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
    await favourites.addAll(data.keys, data.values.toList());
  }

  Future _restore140(Map<String, dynamic> json) async {
    // 收藏
    Map<String, Map<String, dynamic>> fData =
        (json["favourites"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));
    // 竞技场
    Map<String, List> aData = (json["arena"] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as List));
    await favourites.addAll(fData.keys, fData.values.toList());
    await arenaTeam.addAll(aData.keys, aData.values.toList());
  }

  /// [星数基本分，等级系数]
  static const List<List<num>> rarityArenaScore = [
    [47, 68 / 39],
    [49, 73 / 39],
    [51, 79 / 39],
    [53, 84 / 39],
    [55, 7 / 3],
  ];

  /// PersonBuild到Bst的缓存，避免多次计算
  final Map<PersonBuild, int> _builds2Bst = {};

  /// PersonBuild到ArenaScore的缓存，避免多次计算
  final Map<PersonBuild, int> _builds2ArenaScore = {};

  /// 通过PersonBuild计算竞技场档位，内部具有缓存避免重复计算
  int getBstByBuild(
    PersonBuild build,
  ) {
    return _builds2Bst.putIfAbsent(build, () {
      Person hero = cachePersons[build.personTag]!;

      List<Skill?> equipSkills =
          build.equipSkills.map((e) => cacheSkills[e]).toList();

      Stats stat = Stats.fromJson(Utils.calcStats(hero, 1, 40, build.rarity,
          build.advantage, build.disAdvantage, build.merged > 0 ? 1 : 0));

      // 从传承效果、A技能、和白值中计算最高的一个值，突破大于0时白值+3
      // 计算0破性格时已经计算过性格对白值的影响(一般会+-3，优劣性格会+-4，因此总白值相对中性
      // 已经有了-1到+1的补充)，这里不需要计算
      return [
        hero.legendary == null ? 0 : hero.legendary!.bst!,
        equipSkills[3] == null
            ? 0
            // 死斗系技能的timingId等于18
            : equipSkills[3]!.timingId != 18
                ? 0
                // 是否传承或神阶英雄，如果是传承或神阶则使用A技能atk的值（仅限死斗4），
                // 否则使用HP的值
                : hero.legendary?.kind == 1
                    // 死斗3的ATK是0，只有死斗4的ATK > 0
                    ? equipSkills[3]!.skillParams!.atk != 0
                        ? equipSkills[3]!.skillParams!.atk
                        : equipSkills[3]!.skillParams!.hp
                    : equipSkills[3]!.skillParams!.hp,
        // 如果突破数大于0，则数值-2（去掉1破时奖励的不计算bst的2点白值）
        build.merged > 0 ? stat.sum - 2 : stat.sum
      ].reduce((value, element) => m.max(value, element));
    });
  }

  /// 通过PersonBuild计算竞技场英雄个体分，内部具有缓存避免重复计算
  /// 英雄个体分 = 星数基本分 + floor(等级系数*等级) + 突破*2 + floor(技能SP/100) + floor(白值/5) + 祝福*祝福提供者*4
  /// 团队分 = 基础分 + average(英雄个体分1+英雄个体分2+英雄个体分3+英雄个体分4)
  /// 团队分数线 = floor(团队分) * 加分奖励(固定为2)
  /// 这里返回的时个体分，团队分按上面公式计算
  int getArenaScoreByBuild(
    PersonBuild build,
  ) {
    return _builds2ArenaScore.putIfAbsent(build, () {
      List<Skill?> equipSkills =
          build.equipSkills.map((e) => cacheSkills[e]).toList();

      int allSpCost = equipSkills.sublist(0, 8).fold<int>(0,
          (previousValue, element) => previousValue + (element?.spCost ?? 0));

      // 从传承效果、A技能、和白值中计算最高的一个值，突破大于0时白值+3
      // 计算0破性格时已经计算过性格对白值的影响(一般会+-3，优劣性格会+-4，因此总白值相对中性
      // 已经有了-1到+1的补充)，这里不需要计算
      int bst = getBstByBuild(build);

      return (rarityArenaScore[build.rarity - 1][0] as int) +
          ((rarityArenaScore[build.rarity - 1][1] as double) * 40).floor() +
          build.merged * 2 +
          (allSpCost / 100).floor() +
          (bst / 5).floor() +
          (equipSkills[7] == null ? 0 : 4);
    });
  }

  /// 单个角色的新增或编辑
  /// 注意不要单独使用，和favFirstProvider结合使用可以刷新收藏列表
  Future<String> save2Fav({
    String? key,
    required PersonBuild build,
  }) async {
    key ??= DateTime.now().millisecondsSinceEpoch.toString();

    var v = build.toJson();

    await favourites.putIfAbsent(key, v);

    cacheFavHero.putIfAbsent(key, () => PersonBuild.fromJson(key, v));

    return key;
  }

  /// 队伍的新增或编辑
  Future<String> save2Team({
    String? key,
    required List<String?> team,
  }) async {
    var key1 = key ?? DateTime.now().millisecondsSinceEpoch.toString();
    // 这里的team是角色在数据库中的key
    await arenaTeam.putIfAbsent(
      key1,
      team,
    );

    cacheArenateam.putIfAbsent(key1, () => team);

    return key1;
  }

  @override
  Future<Map<String, String>> load(Locale newLocale) async {
    return await loadTranslationData(newLocale);
  }

  // PersonBuild? decodeBuild(String encoded) {
  //   // todo 对于旧版本数据解析到新版本数据的处理，避免数据越界
  //   try {
  //     List<int> all = HashIds().decode(encoded);
  //     PersonBuild? result;

  //     if (all.length < 18) {
  //       throw "解析错误";
  //     }

  //     String personTag = cachePersons.values
  //             .firstWhere(
  //               (element) => element.idNum == all[0],
  //               orElse: () => Person(),
  //             )
  //             .idTag ??
  //         "";
  //     if (personTag.isEmpty) {
  //       // 旧版本数据找不到新版本人物
  //       return null;
  //     }
  //     List<String?> skillsTags = all
  //         .sublist(9, 17)
  //         .map((e) => e == 0
  //             ? null
  //             : cacheSkills.values
  //                 .firstWhere(
  //                   (element) => element.idNum == e,
  //                   orElse: () => Skill(idTag: "SID_CUSTOM_無し"),
  //                 )
  //                 .idTag)
  //         .toList();
  //     result = PersonBuild(
  //       personTag: personTag,
  //       equipSkills: skillsTags,
  //       advantage:
  //           all[1] == 9 ? null : StatsEnum.values[all[1]].name.toLowerCase(),
  //       disAdvantage:
  //           all[2] == 9 ? null : StatsEnum.values[all[2]].name.toLowerCase(),
  //       rarity: all[3],
  //       merged: all[4],
  //       dragonflowers: all[5],
  //       resplendent: all[6] == 1 ? true : false,
  //       summonerSupport: all[7] == 1 ? true : false,
  //       arenaScore: all[8],
  //       ascendedAsset:
  //           all[17] == 9 ? null : StatsEnum.values[all[17]].name.toLowerCase(),
  //     );

  //     return result;
  //   } on Exception catch (e) {
  //     Utils.debug(e.toString());
  //     return null;
  //   }
  // }
}
