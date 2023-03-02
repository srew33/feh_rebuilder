// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/models/base/person_base.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';

class FavFirstState extends Equatable {
  /// 所有的收藏数据，可以通过refresh方法更新
  final List<PersonBuildVM> all;

  /// 通过过滤后的收藏数据
  final List<PersonBuildVM> filtered;

  final Set filters;

  const FavFirstState({
    required this.all,
    required this.filtered,
    required this.filters,
  });

  FavFirstState copyWith({
    List<PersonBuildVM>? all,
    List<PersonBuildVM>? filtered,
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

  factory PersonBuildVM.fromBuild(PersonBuild build, Repository repo) {
    List<Skill?> skills = repo.getSkillsByTags(build.equipSkills);

    int allSp = skills.fold(
        0, (previousValue, element) => previousValue + (element?.spCost ?? 0));

    return PersonBuildVM(
      hero: repo.cachePersons[build.personTag]!,
      skills: skills,
      allSp: allSp,
      arenaScore: repo.getArenaScoreByBuild(build),
      build: build,
    );
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
