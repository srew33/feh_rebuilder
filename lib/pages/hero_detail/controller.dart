import 'dart:async';

import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/hero_detail/model.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final heroDetailPageProvider = AutoDisposeAsyncNotifierProviderFamily<
    HeroDetailPageNotifier,
    HerodetailState,
    PersonBuild>(HeroDetailPageNotifier.new);

class HeroDetailPageNotifier
    extends AutoDisposeFamilyAsyncNotifier<HerodetailState, PersonBuild> {
  @override
  Future<HerodetailState> build(PersonBuild arg) async {
    return await initial(arg);
  }

  Future<HerodetailState> initial(
    PersonBuild initialBuild,
  ) async {
    var repo = ref.read(repoProvider).requireValue;

    List<Skill?> equipSkills;

    Stats refinedWeaponStats = Stats();

    Person hero = await repo.person.mustRead(initialBuild.personTag);

    equipSkills = await repo.getPersonInitialSkills(hero);

    if (initialBuild.equipSkills.isEmpty) {
      // 技能为空时，一般代表默认技能配置
    } else {
      // 不为空，一般代表自定义的技能配置
      var eqs = await repo.skill.readSome(initialBuild.equipSkills);
      // 合并两个技能列表，主要为了获取第9位的专武
      for (var i = 0; i < eqs.length; i++) {
        equipSkills[i] = eqs[i];
      }
    }
    // 如果默认武器位refineId不为空就添加对应的stats，应该仅限从收藏页进入的部分情况才会出现
    if (equipSkills[0]?.refineId != null) {
      refinedWeaponStats
          .add((await repo.skill.read(equipSkills[0]!.refineId!))?.stats);
      // refinedWeaponStats
      //     .add(repo.cacheSkills[equipSkills[0]!.refineId!]?.stats!);
    }

    Map<Skill, Skill?> exclusiveList = {};

    bool hasRefinedWeapon = false;

    // 9是equipSkills的元素数量
    for (var i = 0; i < 9; i++) {
      if (i == 0 || i == 8) {
        if (equipSkills[i]?.exclusive! ?? false) {
          Map<Skill, Skill?> refinedWeapon =
              await Utils.getCanRefineWeapons(equipSkills[i]!.idTag!, repo);
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

  void changeProp(HerodetailPropChanged event) {
    state = AsyncValue.data(state.requireValue.copyWith(
      advantage: event.advantage,
      disAdvantage: event.disAdvantage,
      ascendedAsset: event.ascendedAsset,
      rarity: event.rarity,
      targetLevel: event.targetLevel,
      merged: event.merged,
      dragonflowers: event.dragonflowers,
      resplendent: event.resplendent,
      summonerSupport: event.summonerSupport,
    ));
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
        refinedWeaponStats = (await ref
                .read(repoProvider)
                .requireValue
                .skill
                .mustRead(newSkill!.refineId!))
            .stats;
      }
    }

    List<Skill?> newSkills = [...state.requireValue.equipSkills];
    newSkills[event.index] = newSkill;

    for (var p in EnvProvider.activeBuildCheckers) {
      var r = p.check(state.requireValue.hero, newSkills);
      if (!r.result) {
        Utils.showToast(r.msg);
        return;
      }
    }
    state = AsyncValue.data(state.requireValue.copyWith(
      refinedWeaponStats: refinedWeaponStats,
      equipSkills: newSkills,
    ));
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
