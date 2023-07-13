import 'dart:async';
import 'dart:convert';
import 'dart:math' as m;
import 'dart:ui';

import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/repositories/data_table.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

import 'data_provider.dart';

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
    skillSeries = SkillSeriesTable(db: gameDb.db);

    favourites = FavouritesTable(db: userDb.db);
    arenaTeam = ArenaTeamTable(db: userDb.db);
    config = ConfigTable(db: userDb.db);
  }

  late PersonTable person;
  late SkillTable skill;
  late WeaponTable weapon;
  late TranslationsTable translations;
  late FavouritesTable favourites;
  late ArenaTeamTable arenaTeam;
  late ConfigTable config;
  late SkillSeriesTable skillSeries;

  String get appPath => EnvProvider.rootDir;

  int get version => gameDb.db.version;

  List<PersonBuild> _localBuilds = [];

  FutureOr<List<PersonBuild>> getLocalBuilds(String tag) async {
    if (_localBuilds.isEmpty) {
      final myData = await rootBundle.loadString('assets/builds.json');

      var json = (jsonDecode(myData) as List).cast<List>();

      _localBuilds = json.map((e) => PersonBuild.fromList(e)).toList();
    }

    return _localBuilds.where((element) => element.personTag == tag).toList();
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
    var cacheArenateam = await arenaTeam.getAllRaw();
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

  /// 通过传入的人物模型获取该人物初始化技能
  ///
  /// 顺序为武器、辅助、奥义、A、B、C、S、祝福、需学习的专武
  FutureOr<List<Skill?>> getPersonInitialSkills(Person hero) async {
    // 将二维skills降维,获得一维的技能列表
    List<String?> all =
        hero.skills!.skills.fold<List<String?>>([], (previousValue, element) {
      previousValue.addAll(element);
      return previousValue;
    });

    // 将人物所有技能替换成skill模型
    // List<Skill?> skills =
    //     all.map((e) => e == null ? null : cacheSkills[e]).toList();

    List<Skill?> skills = await skill.readSome(all);

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
  FutureOr<int> getBstByBuild(
    PersonBuild build,
  ) {
    return _builds2Bst.putIfAbsentAsync(build, () async {
      Person? hero = await person.read(build.personTag);

      if (hero == null) {
        return 0;
      }

      List<Skill?> equipSkills = await skill.readSome(build.equipSkills);

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
  FutureOr<int> getArenaScoreByBuild(
    PersonBuild build,
  ) {
    return _builds2ArenaScore.putIfAbsentAsync(build, () async {
      List<Skill?> equipSkills = await skill.readSome(build.equipSkills);

      int allSpCost = equipSkills.sublist(0, 8).fold<int>(0,
          (previousValue, element) => previousValue + (element?.spCost ?? 0));

      // 从传承效果、A技能、和白值中计算最高的一个值，突破大于0时白值+3
      // 计算0破性格时已经计算过性格对白值的影响(一般会+-3，优劣性格会+-4，因此总白值相对中性
      // 已经有了-1到+1的补充)，这里不需要计算
      int bst = await getBstByBuild(build);

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

    // cacheFavHero.putIfAbsent(key, () => PersonBuild.fromJson(key, v));

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

    // cacheArenateam.putIfAbsent(key1, () => team);

    return key1;
  }

  @override
  Future<Map<String, String>> load(Locale newLocale) async {
    return await loadTranslationData(newLocale);
  }

  Future switchGameDB(String newPath) async {
    await gameDb.db.close();

    gameDb = await GameDb(p.join(EnvProvider.rootDir, newPath)).init();

    person = PersonTable(db: gameDb.db);
    skill = SkillTable(db: gameDb.db);
    weapon = WeaponTable(db: gameDb.db);
    translations = TranslationsTable(db: gameDb.db);
    skillSeries = SkillSeriesTable(db: gameDb.db);
  }
}
