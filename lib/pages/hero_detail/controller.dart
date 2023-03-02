import 'dart:async';

import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/hero_detail/model.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final heroDetailPageProvider = AutoDisposeNotifierProviderFamily<
    HeroDetailPageNotifier,
    HerodetailState,
    HerodetailState>(HeroDetailPageNotifier.new);

class HeroDetailPageNotifier
    extends AutoDisposeFamilyNotifier<HerodetailState, HerodetailState> {
  @override
  HerodetailState build(HerodetailState arg) {
    return arg;
  }

  void changeProp(HerodetailPropChanged event) {
    state = state.copyWith(
      advantage: event.advantage,
      disAdvantage: event.disAdvantage,
      ascendedAsset: event.ascendedAsset,
      rarity: event.rarity,
      targetLevel: event.targetLevel,
      merged: event.merged,
      dragonflowers: event.dragonflowers,
      resplendent: event.resplendent,
      summonerSupport: event.summonerSupport,
    );
  }

  Future<void> changeSkill(HerodetailSkillsChanged event) async {
    Skill? newSkill = event.skill;
    Stats? refinedWeaponStats;
    if (event.index == 0) {
      // 如果传入武器类型，为null或refineId为空就直接去掉炼成属性加成，
      // 否则检索refineId技能的stats并替换refinedWeaponStats
      if (newSkill?.refineId == null) {
        refinedWeaponStats = Stats();
      } else {
        refinedWeaponStats = ref
            .read(repoProvider)
            .requireValue
            .cacheSkills[newSkill!.refineId!]!
            .stats;
      }
    }

    List<Skill?> newSkills = [...state.equipSkills];
    newSkills[event.index] = newSkill;

    for (var p in EnvProvider.activeBuildCheckers) {
      var r = p.check(state.hero, newSkills);
      if (!r.result) {
        Utils.showToast(r.msg);
        return;
      }
    }

    state = state.copyWith(
      refinedWeaponStats: refinedWeaponStats,
      equipSkills: newSkills,
    );
  }
}

class HerodetailPropChanged {
  /// 优势属性
  final String? Function()? advantage;

  /// 劣势属性
  final String? Function()? disAdvantage;

  /// 绽放个性属性
  final String? Function()? ascendedAsset;

  /// 稀有度
  final int? rarity;

  /// 突破极限次数
  final int? merged;

  /// 神龙之花次数
  final int? dragonflowers;

  /// 是否购买神装
  final bool? resplendent;

  /// 是否设置召唤师的羁绊
  final bool? summonerSupport;

  /// 目标等级
  final int? targetLevel;

  const HerodetailPropChanged({
    this.advantage,
    this.disAdvantage,
    this.ascendedAsset,
    this.rarity,
    this.merged,
    this.dragonflowers,
    this.resplendent,
    this.summonerSupport,
    this.targetLevel,
  });
}

class HerodetailSkillsChanged {
  /// 新的技能，为null代表去掉
  final Skill? skill;

  /// 技能的序号，注意和类别区分
  final int index;

  const HerodetailSkillsChanged({
    required this.skill,
    required this.index,
  });
}
