import 'package:bloc/bloc.dart';
import 'package:cloud_db/cloud_db.dart';
import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/cloud_object/build_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/api.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';

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
  API api;

  /// 缓存当前列表的点赞数
  // 因为重建该部件时点赞数会从模型获取而在点击按钮时模型没有emit，所以删除时点赞会从原状态读取
  // 导致数量显示错误，考虑到重构复杂度，这里设置了一个缓存用于获取最新的点赞数
  Map<String, int> cacheCount = {};

  Future _onBuildshareStarted(BuildshareStarted event, Emitter emit) async {
    QueryResults? r = await api.getWebBuilds(state.hero.idTag!);

    try {
      Iterable<HeroBuildTable> webModels =
          (r?.results ?? []).map((e) => HeroBuildTable.fromJson(e));

      List<BuildShareVM?> _models =
          webModels.map((e) => webModel2View(e, state.hero)).toList();

      _models.removeWhere((element) => element == null);

      List<BuildShareVM> models = _models.cast<BuildShareVM>();

      for (var model in models) {
        cacheCount.addAll({
          model.tableData.objectId!: model.tableData.likes!.content!.count!
        });
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
    var data = list
        .firstWhere((element) => element.tableData.objectId == event.objectId);
    var r = await api.delWebBuild(data.tableData);
    if (r?.statusCode == 200) {
      list.removeWhere(
          (element) => element.tableData.objectId == event.objectId);
      emit(state.copyWith(buildList: list));
    }
  }

  BuildShareVM? webModel2View(HeroBuildTable tableData, Person hero) {
    PersonBuild? build = repo.decodeBuild(tableData.build ?? "");

    if (build == null) {
      return null;
    } else {
      List<Skill?> skills = build.equipSkills
          .map((e) => e == null ? null : repo.cacheSkills[e])
          .toList();
      Stats skillsStats = Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0);
      for (var _skill in skills) {
        if (_skill != null) {
          skillsStats.add(_skill.stats);
          // 添加武器伤害
          skillsStats.atk += _skill.might!;
          // 对武器炼成后的技能需要考虑添加额外技能的属性，除武器外其他类型的技能暂不考虑
          if (_skill.refineId != null) {
            Skill _refine = repo.cacheSkills[_skill.refineId!]!;
            skillsStats.add(_refine.stats);
          }
        }
      }
      Stats _stats = Stats.fromJson(Utils.calcStats(
        hero,
        1,
        40,
        5,
        build.advantage,
        build.disAdvantage,
        build.merged,
        build.dragonflowers,
        build.resplendent,
        build.summonerSupport,
        build.ascendedAsset,
      ));
      // 合并人物属性和装备属性
      _stats.add(skillsStats);

      return BuildShareVM(
        personBuild: build,
        stats: _stats,
        skills: skills,
        tableData: tableData,
        person: hero,
        arenaScore: repo.getArenaScoreByBuild(build),
      );
    }
  }
}
