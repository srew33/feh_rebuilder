import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'dart:math' as m;

enum HerodetailAction { save, share, upload, webBuild }

class HerodetailState extends Equatable {
  final PageStatus status;
  final String? favKey;
  final Person hero;
  final String? advantage;
  final String? disAdvantage;
  final String? ascendedAsset;
  final int rarity;
  final int merged;
  final int dragonflowers;
  final bool resplendent;
  final bool summonerSupport;
  final int targetLevel;

  /// 人物技能的专有技能字典，key是专有技能，value是武器的锻造效果对应的skill，
  /// 非锻造后的技能则为null
  final Map<Skill, Skill?> exclusiveList;

  /// 是否具有可锻造的武器，在初始化时生成，影响武器炼成的显示
  final bool hasRefinedWeapon;

  /// 由build解析后的技能列表，在页面各种操作中使用
  final List<Skill?> equipSkills;

  /// refineId等可能影响面板的其他技能
  final Stats refinedWeaponStats;

  /// 基础属性，不含技能的属性值
  Stats get baseStats {
    return Stats.fromJson(Utils.calcStats(
      hero,
      1,
      targetLevel,
      rarity,
      advantage,
      disAdvantage,
      merged,
      dragonflowers,
      resplendent,
      summonerSupport,
      ascendedAsset,
    ));
  }

  /// 装备属性，包含了技能、武器锻造等的属性值
  Stats get equipStats {
    Stats result = Stats();
    result.add(baseStats);
    for (Skill? s in equipSkills.getRange(0, 8)) {
      if (s != null) {
        result.atk += s.might!;
        result.add(s.stats);
        // tempStats.add(skillStats);
      }
    }

    result.add(refinedWeaponStats);

    return result;
  }

  /// 竞技场档位
  int get bst {
    Stats stats = Stats.fromJson(Utils.calcStats(
        hero, 1, 40, rarity, advantage, disAdvantage, merged > 0 ? 1 : 0));

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
      merged > 0 ? stats.sum - 2 : stats.sum
    ].reduce((value, element) => m.max(value, element));
  }

  ///竞技场分数
  int get arenaScore {
// 英雄个体分 =
//星数基本分 + floor(等级系数*等级) + 突破*2 + floor(技能SP/100) + floor(白值/5) + 祝福*祝福提供者*4
// 团队分 = (average(英雄个体分1+英雄个体分2+英雄个体分3+英雄个体分4) +150(团队基础分))*2(加分人物奖励)
    return ((Repository.rarityArenaScore[rarity - 1][0] as int) +
            ((Repository.rarityArenaScore[rarity - 1][1] as double) *
                    targetLevel)
                .floor() +
            merged * 2 +
            (allSpCost / 100).floor() +
            (bst / 5).floor() +
            (equipSkills[7] == null ? 0 : 4) +
            150) *
        2;
  }

  // equipSkills共9位，最后一位是可锻造的武器，会影响计算，这里要去掉
  int get allSpCost => equipSkills.sublist(0, 8).fold<int>(
      0, (previousValue, element) => previousValue + (element?.spCost ?? 0));

  // ignore: non_constant_identifier_names
  static HerodetailState DEFAULT = HerodetailState(
    status: PageStatus.initial,
    hero: Person(),
    hasRefinedWeapon: false,
    refinedWeaponStats: Stats(),
  );

  const HerodetailState({
    required this.status,
    this.favKey,
    required this.hero,
    this.advantage,
    this.disAdvantage,
    this.ascendedAsset,
    this.rarity = 5,
    this.merged = 0,
    this.dragonflowers = 0,
    this.resplendent = false,
    this.summonerSupport = false,
    this.targetLevel = 40,
    this.exclusiveList = const {},
    required this.hasRefinedWeapon,
    this.equipSkills = const [null, null, null, null, null, null, null, null],
    required this.refinedWeaponStats,
  });

  @override
  List<Object> get props => [
        status,
        hero.idTag ?? "",
        advantage ?? "",
        disAdvantage ?? "",
        ascendedAsset ?? "",
        rarity,
        merged,
        dragonflowers,
        resplendent,
        summonerSupport,
        equipSkills,
        targetLevel,
        hasRefinedWeapon,
        refinedWeaponStats,
        targetLevel,
      ];

  HerodetailState copyWith({
    PageStatus? status,
    Person? hero,
    String? Function()? advantage,
    String? Function()? disAdvantage,
    String? Function()? ascendedAsset,
    int? rarity,
    int? targetLevel,
    int? merged,
    int? dragonflowers,
    bool? resplendent,
    bool? summonerSupport,
    Map<Skill, Skill>? exclusiveList,
    List<Skill?>? equipSkills,
    Stats? refinedWeaponStats,
  }) {
    return HerodetailState(
      status: status ?? this.status,
      hero: hero ?? this.hero,
      favKey: favKey,
      advantage: advantage == null ? this.advantage : advantage.call(),
      disAdvantage:
          disAdvantage == null ? this.disAdvantage : disAdvantage.call(),
      ascendedAsset:
          ascendedAsset == null ? this.ascendedAsset : ascendedAsset.call(),
      rarity: rarity ?? this.rarity,
      targetLevel: targetLevel ?? this.targetLevel,
      merged: merged ?? this.merged,
      dragonflowers: dragonflowers ?? this.dragonflowers,
      resplendent: resplendent ?? this.resplendent,
      summonerSupport: summonerSupport ?? this.summonerSupport,
      equipSkills: equipSkills ?? this.equipSkills,
      refinedWeaponStats: refinedWeaponStats ?? this.refinedWeaponStats,
      exclusiveList: exclusiveList ?? this.exclusiveList,
      hasRefinedWeapon: hasRefinedWeapon,
    );
  }

  PersonBuild get currentBuild {
    return PersonBuild(
      personTag: hero.idTag!,
      advantage: advantage,
      disAdvantage: disAdvantage,
      ascendedAsset: ascendedAsset,
      rarity: 5,
      merged: merged,
      dragonflowers: dragonflowers,
      resplendent: resplendent,
      summonerSupport: summonerSupport,
      equipSkills: equipSkills.map((e) => e?.idTag!).toList(),
    );
  }

  static Future<HerodetailState> initial(
      PersonBuild initialBuild, Repository repo) async {
    List<Skill?> equipSkills;

    Stats refinedWeaponStats = Stats();

    Person hero = repo.cachePersons[initialBuild.personTag]!;

    equipSkills = repo.getPersonInitialSkills(hero);

    if (initialBuild.equipSkills.isEmpty) {
      // 技能为空时，一般代表默认技能配置
    } else {
      // 不为空，一般代表自定义的技能配置
      var eqs = repo.getSkillsByTags(initialBuild.equipSkills);
      // 合并两个技能列表，主要为了获取第9位的专武
      for (var i = 0; i < eqs.length; i++) {
        equipSkills[i] = eqs[i];
      }
    }
    // 如果默认武器位refineId不为空就添加对应的stats，应该仅限从收藏页进入的部分情况才会出现
    if (equipSkills[0]?.refineId != null) {
      refinedWeaponStats
          .add(repo.cacheSkills[equipSkills[0]!.refineId!]?.stats!);
    }

    Map<Skill, Skill?> exclusiveList = {};

    bool hasRefinedWeapon = false;

    // 9是equipSkills的元素数量
    for (var i = 0; i < 9; i++) {
      if (i == 0 || i == 8) {
        if (equipSkills[i]?.exclusive! ?? false) {
          Map<Skill, Skill?> refinedWeapon =
              Utils.getCanRefineWeapons(equipSkills[i]!.idTag!, repo);
          exclusiveList.addAll(refinedWeapon);
          // 如果有存在锻造效果，则代表该人物有锻造武器，将显示武器炼成的内容
          hasRefinedWeapon =
              refinedWeapon.values.any((element) => element != null);
        }
      } else {
        if ((equipSkills[i]?.exclusive! ?? false)) {
          exclusiveList.addAll({equipSkills[i]!: null});
        }
      }
    }

    return HerodetailState(
      status: PageStatus.normal,
      hero: hero,
      equipSkills: equipSkills,
      advantage: initialBuild.advantage,
      disAdvantage: initialBuild.disAdvantage,
      rarity: initialBuild.rarity,
      merged: initialBuild.merged,
      dragonflowers: initialBuild.dragonflowers,
      resplendent: initialBuild.resplendent,
      summonerSupport: initialBuild.summonerSupport,
      exclusiveList: exclusiveList,
      refinedWeaponStats: refinedWeaponStats,
      hasRefinedWeapon: hasRefinedWeapon,
      ascendedAsset: initialBuild.ascendedAsset,
      // baseStats: baseStats,
      // skillsStats: skillsStats,
      // exclusiveList: initBuild.,
    );
  }
}
