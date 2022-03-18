part of 'herodetail_bloc.dart';

abstract class HerodetailEvent extends Equatable {
  const HerodetailEvent();

  @override
  List<Object> get props => [];
}

class HerodetailInited extends HerodetailEvent {
  /// 初始化的build
  final PersonBuild initialBuild;

  /// [build] 初始化的build
  const HerodetailInited({required this.initialBuild});
}

class HerodetailPropChanged extends HerodetailEvent {
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

class HerodetailSkillsChanged extends HerodetailEvent {
  /// 新的技能，为null代表去掉
  final Skill? skill;

  /// 技能的序号，注意和类别区分
  final int index;

  const HerodetailSkillsChanged({
    required this.skill,
    required this.index,
  });
}
