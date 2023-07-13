import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'dart:math' as m;

enum HerodetailAction { save, share, upload, webBuild }

class HerodetailState extends Equatable {
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

  const HerodetailState({
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
}
