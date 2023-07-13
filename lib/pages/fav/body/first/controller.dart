import 'dart:async';

import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/fav/body/second/controller.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model.dart';

final favFirstIsGroupingProvider = StateProvider<bool>((ref) {
  return false;
});

final favFirstProvider = AsyncNotifierProvider<FavFirstNotifier, FavFirstState>(
    FavFirstNotifier.new);

class FavFirstNotifier extends AsyncNotifier<FavFirstState> {
  @override
  FutureOr<FavFirstState> build() async {
    var repo = ref.read(repoProvider).requireValue;
    List<PersonBuildVM?> allFav = [];

    var allFav_ = await repo.favourites.getAll();

    for (var e in allFav_.entries) {
      // 这里会有异常
      var v = await PersonBuildVM.fromBuild(e.value, repo);
      allFav.add(v);
    }
    return FavFirstState(all: allFav, filtered: [...allFav], filters: const {});
  }

  /// 新增/保存build，触发收藏页和队伍页更新
  Future<void> saveBuild({
    String? key,
    required PersonBuild build,
  }) async {
    state = await AsyncValue.guard(() async {
      var s = state.value!;

      var repo = ref.read(repoProvider).requireValue;
      var key1 = await repo.save2Fav(
        build: build,
        key: key,
      );
      var all = [...s.all];
      if (key == null) {
        // 新增
        all.add(await PersonBuildVM.fromBuild(
            PersonBuild.fromJson(key1, build.toJson()), repo));
      } else {
        // 保存
        // all里的key必不为null
        int i = all.indexWhere(
            (element) => element == null ? false : element.build.key == key);

        if (i != -1) {
          var newBuild = await PersonBuildVM.fromBuild(
              PersonBuild.fromJson(key, build.toJson()), repo);
          if (newBuild != null) {
            all[i] = newBuild;
            ref.read(favSecondProvider.notifier).updateBuild(newBuild);
          }
        }
      }
      List<PersonBuildVM?> filtered = _filt(all, s.filters);
      return s.copyWith(
        filtered: filtered,
        all: all,
      );
    });
  }

  Future<void> confirmFilter(Set filters) async {
    state = await AsyncValue.guard(() async {
      var s = state.value!;
      List<PersonBuildVM?> filtered = _filt(s.all, filters);

      return s.copyWith(
        filtered: filtered,
        filters: filters,
      );
    });
  }

  Future<void> saveTeam(List<String?> team, [String? key]) async {
    if (team.every((element) => element == null)) {
      Utils.showToast("队伍不能为空");
    } else {
      try {
        await ref
            .read(repoProvider)
            .requireValue
            .save2Team(key: key, team: team);
        Utils.showToast("保存成功");
      } catch (e) {
        Utils.showToast("保存失败: ${e.toString()}");
      }
    }
  }

  Future<void> delete(Set<int> selected) async {
    state = await AsyncValue.guard(() async {
      var s = state.value!;

      // 从大到小排列并删除对应元素
      var s1 = selected.toList();
      s1.sort((a, b) => b.compareTo(a));

      List<PersonBuildVM?> n = [...s.filtered];
      List<String> keys = [];
      for (var i in s1) {
        if (n[i] != null) {
          keys.add(n[i]!.build.key!);
          n.removeAt(i);
        }
      }

      if (keys.isEmpty) {
        return s;
      }
      var repo = ref.read(repoProvider).requireValue;
      await repo.favourites.deleteSome(keys);

      // 队伍列表刷新
      ref.read(favSecondProvider.notifier).refresh();
      return s.copyWith(all: n, filtered: n);
    });
  }

  List<PersonBuildVM?> _filt(List<PersonBuildVM?> all, Set filters) {
    List<PersonFilter> personFilters = [];
    Set<MoveTypeEnum> moveValid = {};
    Set<WeaponTypeEnum> weaponValid = {};
    Set<SeriesEnum> seriesValid = {};
    Set<GameVersionEnum> gameVersionValid = {};
    Set<PersonTypeEnum> personTypeValid = {};

    for (var type in filters) {
      switch (type.runtimeType) {
        case MoveTypeEnum:
          moveValid.add(type);
          break;
        case WeaponTypeEnum:
          weaponValid.add(type);
          break;
        case SeriesEnum:
          seriesValid.add(type);
          break;
        case GameVersionEnum:
          gameVersionValid.add(type);
          break;
        case PersonTypeEnum:
          personTypeValid.add(type);
          break;
        default:
          // personFilters.add(PersonFilter(filterType: type, valid: null));
          break;
      }
    }

    if (moveValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.moveType, valid: moveValid));
    }
    if (weaponValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.weaponType, valid: weaponValid));
    }
    if (seriesValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.series, valid: seriesValid));
    }
    if (gameVersionValid.isNotEmpty) {
      personFilters.add(
        PersonFilter(
          filterType: PersonFilterEnum.gameVersion,
          valid: gameVersionValid,
        ),
      );
    }
    if (personTypeValid.isNotEmpty) {
      personFilters.add(
        PersonFilter(
          filterType: PersonFilterEnum.personType,
          valid: personTypeValid,
        ),
      );
    }
    var chain = FilterChain(input: all, filters: personFilters);

    List<PersonBuildVM?> filtered = [...chain.output].cast<PersonBuildVM?>();

    return filtered;
  }
}
