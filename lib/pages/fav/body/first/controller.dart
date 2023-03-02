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

enum FavPageModeEnum { normal, select }

final favFirstIsGroupingProvider = StateProvider<bool>((ref) {
  return false;
});

final favFirstProvider =
    NotifierProvider<FavFirstNotifier, FavFirstState>(FavFirstNotifier.new);

class FavFirstNotifier extends Notifier<FavFirstState> {
  @override
  FavFirstState build() {
    var repo = ref.read(repoProvider).requireValue;
    var allFav = repo.cacheFavHero.entries
        .map(
          (e) => PersonBuildVM.fromBuild(e.value, repo),
        )
        .toList();
    return FavFirstState(all: allFav, filtered: [...allFav], filters: const {});
  }

  void initial() {
    var repo = ref.read(repoProvider).requireValue;
    var allFav = repo.cacheFavHero.entries
        .map(
          (e) => PersonBuildVM.fromBuild(e.value, repo),
        )
        .toList();
    state =
        FavFirstState(all: allFav, filtered: [...allFav], filters: const {});
  }

  /// 新增/保存build，触发收藏页和队伍页更新
  Future<void> saveBuild({
    String? key,
    required PersonBuild build,
  }) async {
    var repo = ref.read(repoProvider).requireValue;
    var key1 = await repo.save2Fav(
      build: build,
      key: key,
    );

    var all = [...state.all];
    if (key == null) {
      // 新增
      all.add(PersonBuildVM.fromBuild(
          PersonBuild.fromJson(key1, build.toJson()), repo));
    } else {
      // 保存
      // all里的key必不为null
      int i = all.indexWhere((element) => element.build.key == key);
      if (i != -1) {
        var newBuild = PersonBuildVM.fromBuild(
            PersonBuild.fromJson(key, build.toJson()), repo);
        all[i] = newBuild;
        ref.read(favSecondProvider.notifier).updateBuild(newBuild);
      }
    }
    List<PersonBuildVM> filtered = _filt(all, state.filters);
    state = state.copyWith(
      filtered: filtered,
      all: all,
    );
  }

  void confirmFilter(Set filters) {
    List<PersonBuildVM> filtered = _filt(state.all, filters);

    state = state.copyWith(
      filtered: filtered,
      filters: filters,
    );
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
    // 从大到小排列并删除对应元素
    var s1 = selected.toList();
    s1.sort((a, b) => b.compareTo(a));

    List<PersonBuildVM> n = [...state.filtered];
    List<String> keys = [];
    for (var i in s1) {
      keys.add(n[i].build.key!);
      n.removeAt(i);
    }

    if (keys.isEmpty) {
      return;
    }
    var repo = ref.read(repoProvider).requireValue;
    await repo.favourites.deleteSome(keys);
    // 删除缓存
    for (var key in keys) {
      repo.cacheFavHero.remove(key);
    }
    // 队伍列表刷新
    ref.read(favSecondProvider.notifier).refresh();
    state = state.copyWith(all: n, filtered: n);
  }

  List<PersonBuildVM> _filt(List<PersonBuildVM> all, Set filters) {
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

    List<PersonBuildVM> filtered = [...chain.output].cast<PersonBuildVM>();

    return filtered;
  }
}
