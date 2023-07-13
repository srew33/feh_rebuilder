import 'dart:async';

import 'package:feh_rebuilder/pages/fav/body/first/model.dart';
import 'package:feh_rebuilder/pages/local_builds/model.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localBuildsPageProvider = AutoDisposeAsyncNotifierProviderFamily<
    LocalBuildsPageNotifierNotifier,
    LocalBuildsPageState,
    String>(LocalBuildsPageNotifierNotifier.new);

class LocalBuildsPageNotifierNotifier
    extends AutoDisposeFamilyAsyncNotifier<LocalBuildsPageState, String> {
  @override
  FutureOr<LocalBuildsPageState> build(String arg) async {
    List<PersonBuildVM> buildsVM = [];

    var repo = ref.read(repoProvider).requireValue;

    var builds = await repo.getLocalBuilds(arg);

    for (var i = 0; i < builds.length; i++) {
      var b_ = await PersonBuildVM.fromBuild(builds[i], repo);
      if (b_ != null) {
        buildsVM.add(b_);
      }
    }

    return LocalBuildsPageState(
      builds: buildsVM,
    );
  }
}
