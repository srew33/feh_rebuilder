import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'dart:math' as m;

import 'package:feh_rebuilder/utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'herodetail_event.dart';
part 'herodetail_state.dart';

class HerodetailBloc extends Bloc<HerodetailEvent, HerodetailState> {
  HerodetailBloc({
    required this.repo,
    required Person hero,
    String? favKey,
  }) : super(HerodetailState(
          status: StateStatus.initial,
          favKey: favKey,
          hero: hero,
          hasRefinedWeapon: false,
          refinedWeaponStats: Stats(),
        )) {
    on<HerodetailInited>(_onHerodetailInited);
    on<HerodetailPropChanged>(_onHerodetailPropChanged);
    on<HerodetailSkillsChanged>(_onHerodetailSkillsChanged);
  }
  Repository repo;

  /// 响应初始化事件
  Future<void> _onHerodetailInited(HerodetailInited event, Emitter emit) async {
    PersonBuild initBuild = event.initialBuild;

    List<Skill?> equipSkills;

    Stats refinedWeaponStats = Stats();

    equipSkills = repo.getPersonInitialSkills(state.hero);

    if (initBuild.equipSkills.isEmpty) {
      // 技能为空时，一般代表默认技能配置

    } else {
      // 不为空，一般代表自定义的技能配置
      var _equipSkills = repo.getSkillsByTags(initBuild.equipSkills);
      // 合并两个技能列表，主要为了获取第9位的专武
      for (var i = 0; i < _equipSkills.length; i++) {
        equipSkills[i] = _equipSkills[i];
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

    emit(HerodetailState(
      status: StateStatus.success,
      hero: state.hero,
      favKey: state.favKey,
      equipSkills: equipSkills,
      advantage: initBuild.advantage,
      disAdvantage: initBuild.disAdvantage,
      rarity: initBuild.rarity,
      merged: initBuild.merged,
      dragonflowers: initBuild.dragonflowers,
      resplendent: initBuild.resplendent,
      summonerSupport: initBuild.summonerSupport,
      exclusiveList: exclusiveList,
      refinedWeaponStats: refinedWeaponStats,
      hasRefinedWeapon: hasRefinedWeapon,
      // baseStats: baseStats,
      // skillsStats: skillsStats,
      // exclusiveList: initBuild.,
    ));
  }

  /// 响应属性变化事件
  void _onHerodetailPropChanged(HerodetailPropChanged event, Emitter emit) {
    emit(state.copyWith(
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

  /// 响应技能变化事件
  Future<void> _onHerodetailSkillsChanged(
      HerodetailSkillsChanged event, Emitter emit) async {
    Skill? newSkill = event.skill;
    Stats? refinedWeaponStats;
    if (event.index == 0) {
      // 如果传入武器类型，为null或refineId为空就直接去掉炼成属性加成，
      // 否则检索refineId技能的stats并替换refinedWeaponStats
      if (newSkill?.refineId == null) {
        refinedWeaponStats = Stats();
      } else {
        refinedWeaponStats = repo.cacheSkills[newSkill!.refineId!]!.stats;
      }
    }

    List<Skill?> newSkills = [...state.equipSkills];
    newSkills[event.index] = newSkill;

    emit(state.copyWith(
      refinedWeaponStats: refinedWeaponStats,
      equipSkills: newSkills,
    ));
  }
}
