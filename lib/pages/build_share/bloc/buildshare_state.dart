part of 'buildshare_bloc.dart';

class BuildshareState extends Equatable {
  const BuildshareState({
    required this.hero,
    required this.status,
    required this.buildList,
  });

  final Person hero;
  final StateStatus status;
  final List<BuildShareVM> buildList;

  @override
  List<Object> get props => [buildList];

  BuildshareState copyWith({
    StateStatus? status,
    List<BuildShareVM>? buildList,
  }) {
    return BuildshareState(
      hero: hero,
      status: status ?? this.status,
      buildList: buildList ?? this.buildList,
    );
  }
}

class BuildShareVM extends Equatable {
  final PersonBuild personBuild;

  final Stats stats;
  final Person person;
  final int arenaScore;
  final List<Skill?> skills;
  final HeroBuildTable tableData;

  const BuildShareVM({
    required this.personBuild,
    required this.stats,
    required this.person,
    required this.arenaScore,
    required this.skills,
    required this.tableData,
  });

  @override
  List<Object?> get props => [personBuild];
}
