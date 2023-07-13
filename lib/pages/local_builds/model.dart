import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/pages/fav/body/first/model.dart';

class LocalBuildsPageState extends Equatable {
  final List<PersonBuildVM> builds;

  const LocalBuildsPageState({
    this.builds = const [],
  });

  LocalBuildsPageState copyWith({
    List<PersonBuildVM>? builds,
  }) {
    return LocalBuildsPageState(
      builds: builds ?? this.builds,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [builds];
}
