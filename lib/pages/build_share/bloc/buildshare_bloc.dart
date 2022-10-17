import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/net_service/base_api.dart';

part 'buildshare_event.dart';
part 'buildshare_state.dart';

class BuildshareBloc extends Bloc<BuildshareEvent, BuildshareState> {
  BuildshareBloc({
    required this.repo,
    required this.api,
    required Person hero,
  }) : super(BuildshareState(
          buildList: const [],
          hero: hero,
          status: StateStatus.initial,
        )) {
    on<BuildshareStarted>(_onBuildshareStarted);
    on<BuildshareLiked>(_onBuildshareLiked);
    on<BuildshareDeleted>(_onBuildshareDeleted);
  }
  Repository repo;
  BaseNetService api;

  /// 缓存当前列表的点赞数
  // 因为重建该部件时点赞数会从模型获取而在点击按钮时模型没有emit，所以删除时点赞会从原状态读取
  // 导致数量显示错误，考虑到重构复杂度，这里设置了一个缓存用于获取最新的点赞数
  Map<String, int> cacheCount = {};

  Future _onBuildshareStarted(BuildshareStarted event, Emitter emit) async {
    List<NetBuild> r = await api.getWebBuilds(state.hero.idTag!);

    try {
      List<BuildShareVM> models =
          r.map((e) => webModel2View(e, state.hero)).toList();

      // _models.removeWhere((element) => element == null);

      // List<BuildShareVM> models = _models.cast<BuildShareVM>();

      for (var model in models) {
        cacheCount.addAll({model.netBuild.objectId!: model.netBuild.count});
      }
      emit(state.copyWith(
        status: StateStatus.success,
        buildList: models,
      ));
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      Utils.debug(e.toString());
      Utils.showToast("解析数据出错");
    }
  }

  void _onBuildshareLiked(BuildshareLiked event, Emitter emit) {
    cacheCount[event.objectId] = event.newCount;
  }

  Future _onBuildshareDeleted(BuildshareDeleted event, Emitter emit) async {
    var list = [...state.buildList];
    // var data = list.firstWhere((element) => element.objectId == event.objectId);
    await api.delWebBuild(event.netBuild);

    list.removeWhere(
        (element) => element.netBuild.objectId == event.netBuild.objectId);
    emit(state.copyWith(buildList: list));
  }

  BuildShareVM webModel2View(NetBuild netBuild, Person hero) {
    PersonBuild personBuild = netBuild.build;
    List<Skill?> skills = netBuild.build.equipSkills
        .map((e) => e == null ? null : repo.cacheSkills[e])
        .toList();
    Stats skillsStats = Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0);
    for (var skill in skills) {
      if (skill != null) {
        skillsStats.add(skill.stats);
        // 添加武器伤害
        skillsStats.atk += skill.might!;
        // 对武器炼成后的技能需要考虑添加额外技能的属性，除武器外其他类型的技能暂不考虑
        if (skill.refineId != null) {
          Skill refine = repo.cacheSkills[skill.refineId!]!;
          skillsStats.add(refine.stats);
        }
      }
    }
    Stats stats = Stats.fromJson(Utils.calcStats(
      hero,
      1,
      40,
      5,
      personBuild.advantage,
      personBuild.disAdvantage,
      personBuild.merged,
      personBuild.dragonflowers,
      personBuild.resplendent,
      personBuild.summonerSupport,
      personBuild.ascendedAsset,
    ));
    // 合并人物属性和装备属性
    stats.add(skillsStats);

    return BuildShareVM(
      stats: stats,
      skills: skills,
      person: hero,
      arenaScore: repo.getArenaScoreByBuild(personBuild),
      netBuild: netBuild,
    );
  }
}
