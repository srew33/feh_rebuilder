// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/models/base/person_base.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';

class FavFirstState extends Equatable {
  /// 所有的收藏数据，可以通过refresh方法更新
  final List<PersonBuildVM?> all;

  /// 通过过滤后的收藏数据
  final List<PersonBuildVM?> filtered;

  final Set filters;

  const FavFirstState({
    required this.all,
    required this.filtered,
    required this.filters,
  });

  FavFirstState copyWith({
    List<PersonBuildVM?>? all,
    List<PersonBuildVM?>? filtered,
    Set? filters,
  }) {
    return FavFirstState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [all, filtered, filters];
}

class PersonBuildVM extends Equatable implements BasePerson {
  const PersonBuildVM({
    required this.hero,
    required this.skills,
    required this.allSp,
    required this.arenaScore,
    required this.build,
  });

  final Person hero;
  final List<Skill?> skills;
  final int allSp;
  final int arenaScore;
  final PersonBuild build;

  @override
  List<Object?> get props => [hero, skills, allSp];

  static FutureOr<PersonBuildVM?> fromBuild(
      PersonBuild build, Repository repo) async {
    List<Skill?> skills = await repo.skill.readSome(build.equipSkills);

    int allSp = skills.fold(
        0, (previousValue, element) => previousValue + (element?.spCost ?? 0));

    var p = await repo.person.read(build.personTag);

    if (p == null) {
      return null;
    }

    return PersonBuildVM(
      hero: p,
      skills: skills,
      allSp: allSp,
      arenaScore: await repo.getArenaScoreByBuild(build),
      build: build,
    );
  }

  Future<Stats> getStats(Repository repo) async {
    List<Skill?> skills = await repo.skill.readSome(build.equipSkills);
    // List<Skill?> skills = netBuild.build.equipSkills
    //     .map((e) => e == null ? null : repo.cacheSkills[e])
    //     .toList();
    Stats skillsStats = Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0);
    for (var skill in skills) {
      if (skill != null) {
        skillsStats.add(skill.stats);
        // 添加武器伤害
        skillsStats.atk += skill.might!;
        // 对武器炼成后的技能需要考虑添加额外技能的属性，除武器外其他类型的技能暂不考虑
        if (skill.refineId != null) {
          Skill refine = await repo.skill.mustRead(skill.refineId!);
          skillsStats.add(refine.stats);
        }
      }
    }
    Stats stats = Stats.fromJson(Utils.calcStats(
      hero,
      1,
      40,
      5,
      build.advantage,
      build.disAdvantage,
      build.merged,
      build.dragonflowers,
      build.resplendent,
      build.summonerSupport,
      build.ascendedAsset,
    ));
    // 合并人物属性和装备属性
    stats.add(skillsStats);

    return stats;
  }

  @override
  Person get person => hero;

  PersonBuildVM copyWith({
    Person? hero,
    List<Skill?>? skills,
    int? allSp,
    int? arenaScore,
    PersonBuild? build,
    bool? selected,
  }) {
    return PersonBuildVM(
      hero: hero ?? this.hero,
      skills: skills ?? this.skills,
      allSp: allSp ?? this.allSp,
      arenaScore: arenaScore ?? this.arenaScore,
      build: build ?? this.build,
    );
  }
}
