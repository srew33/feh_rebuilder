part of 'favscreen_bloc.dart';

class FavscreenState extends Equatable {
  const FavscreenState({
    required this.status,
    required this.all,
    required this.selected,
  });

  final StateStatus status;
  final List<FavModel> all;
  final Set<String> selected;

  @override
  List<Object> get props => [
        status,
        all,
        selected,
      ];

  FavscreenState copyWith({
    StateStatus? status,
    List<FavModel>? all,
    Set<String>? selected,
  }) {
    return FavscreenState(
      status: status ?? this.status,
      all: all ?? this.all,
      selected: selected ?? this.selected,
    );
  }
}

class FavModel {
  final String key;
  final Person hero;
  final PersonBuild personBuild;
  FavModel({
    required this.key,
    required this.hero,
    required this.personBuild,
  });
  // final List<Skill?> skills;

}
