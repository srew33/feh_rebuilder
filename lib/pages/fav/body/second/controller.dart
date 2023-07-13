import 'dart:async';

import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/person.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../first/model.dart';
import 'model.dart';

final favSecondProvider =
    AsyncNotifierProvider<FavSecondNotifier, FavSecondState>(
        FavSecondNotifier.new);

class FavSecondNotifier extends AsyncNotifier<FavSecondState> {
  @override
  Future<FavSecondState> build() async {
    var allFav = await _refreshAll();

    return FavSecondState(all: allFav, filtered: [...allFav]);
  }

  Future<List<FavSecondItemModel>> _refreshAll() async {
    var repo = ref.read(repoProvider).requireValue;

    List<FavSecondItemModel> allFav = [];

    var allTeam = await repo.arenaTeam.getAll();

    var allFav_ = await repo.favourites.getAll();

    for (var team in allTeam.entries) {
      Iterable<PersonBuildVM?> a = await Future.wait(team.value.map((e2) async {
        if (e2 == null || !allFav_.containsKey(e2)) {
          return null;
        }
        return PersonBuildVM.fromBuild(allFav_[e2]!, repo);
      }));

      if (a.any((element) => element != null)) {
        allFav.add(FavSecondItemModel(team.key, a.toList()));
      }
    }

    return allFav;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      var allFav = await _refreshAll();

      return s.copyWith(all: allFav, filtered: [...allFav]);
    });
  }

  Future<void> updateBuild(PersonBuildVM newBuild) async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      bool shouldUpdate = false;
      var all = [...s.all];
      for (var i = 0; i < all.length; i++) {
        for (var j = 0; j < all[i].data.length; j++) {
          if (all[i].data[j]?.build.key == newBuild.build.key) {
            all[i].data[j] = newBuild;
            shouldUpdate = true;
          }
        }
      }

      if (shouldUpdate) {
        return s.copyWith(all: all, filtered: [...all]);
      } else {
        return s;
      }
    });
  }

  Future<void> save(List<String?> team, [String? key]) async {
    if (team.every((element) => element == null)) {
      Utils.showToast("队伍不能为空");
    } else {
      try {
        var repo = ref.read(repoProvider).requireValue;
        await repo.save2Team(team: team, key: key);

        // repo.cacheArenateam[k] = team;
        // 刷新列表,为了确保数据正确，这里还是直接从数据库读取
        refresh();
        Utils.showToast("保存成功");
      } catch (e) {
        Utils.showToast("保存失败: ${e.toString()}");
      }
    }
  }

  Future<void> delete(int index) async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      var n = [...s.filtered];
      await ref.read(repoProvider).requireValue.arenaTeam.delete(n[index].key);

      n.removeAt(index);

      return s.copyWith(filtered: n);
    });
  }

  Future<void> deleteSome(Set<int> selected) async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      // 从大到小排列并删除对应元素
      var s1 = selected.toList();
      s1.sort((a, b) => b.compareTo(a));

      List<FavSecondItemModel> n = [...s.filtered];
      List<String> keys = [];
      for (var i in s1) {
        keys.add(n[i].key);
        n.removeAt(i);
      }

      if (keys.isEmpty) {
        return s;
      }
      var repo = ref.read(repoProvider).requireValue;
      await repo.arenaTeam.deleteSome(keys);

      return s.copyWith(filtered: n);
    });
  }

  Future<void> confirmFilter(Set filters) async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      List<FavSecondItemModel> filtered = _filt(s.all, filters);

      return s.copyWith(
        filtered: filtered,
      );
    });
  }
}

List<FavSecondItemModel> _filt(List<FavSecondItemModel> all, Set filters) {
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
    personFilters.add(
        PersonFilter(filterType: PersonFilterEnum.moveType, valid: moveValid));
  }
  if (weaponValid.isNotEmpty) {
    personFilters.add(PersonFilter(
        filterType: PersonFilterEnum.weaponType, valid: weaponValid));
  }
  if (seriesValid.isNotEmpty) {
    personFilters.add(
        PersonFilter(filterType: PersonFilterEnum.series, valid: seriesValid));
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

  List<FavSecondItemModel> filtered = [];

  for (var i = 0; i < all.length; i++) {
    var chain = FilterChain(input: all[i].data, filters: personFilters);
    if ((chain.output.cast<PersonBuildVM>()).isNotEmpty) {
      filtered.add(all[i]);
    }
  }

  return filtered;
}
