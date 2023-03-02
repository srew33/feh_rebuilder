// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';

class BuildshareState extends Equatable {
  const BuildshareState({
    required this.hero,
    required this.buildList,
  });

  final Person hero;

  final List<BuildShareVM> buildList;

  @override
  List<Object> get props => [buildList];

  BuildshareState copyWith({
    List<BuildShareVM>? buildList,
  }) {
    return BuildshareState(
      hero: hero,
      buildList: buildList ?? this.buildList,
    );
  }
}

class BuildShareVM extends Equatable {
  // final PersonBuild personBuild;

  final Person person;
  final int arenaScore;
  final List<Skill?> skills;
  final NetBuildBusinessModel netBuild;
  final Stats stats;
  // final String objectId;
  // final int likes;
  // final String creator;

  const BuildShareVM({
    required this.person,
    required this.arenaScore,
    required this.skills,
    required this.netBuild,
    required this.stats,
  });

  @override
  List<Object?> get props => [netBuild.build];
}
