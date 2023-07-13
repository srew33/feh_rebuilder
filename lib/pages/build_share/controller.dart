import 'dart:async';

import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/net_service/service.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

final buildShareProvider = AutoDisposeAsyncNotifierProviderFamily<
    NetBuildNotifier, BuildshareState, String>(NetBuildNotifier.new);

class NetBuildNotifier
    extends AutoDisposeFamilyAsyncNotifier<BuildshareState, String> {
  late final Person _person;

  @override
  FutureOr<BuildshareState> build(String arg) async {
    var repo = ref.read(repoProvider).requireValue;
    // 可能要处理null情况
    _person = await repo.person.mustRead(arg);

    var netService = ref.read(netProvider);

    await netService.initService();

    List<NetBuildBusinessModel> r =
        await netService.getWebBuilds(_person.idTag!);
    List<BuildShareVM> models = [];

    for (var i = 0; i < r.length; i++) {
      models.add(await webModel2View(r[i]));
    }
    // List<BuildShareVM> models = r.map((e) => webModel2View(e)).toList();

    return BuildshareState(
      hero: _person,
      buildList: models,
    );
  }

  Future<void> deleteBuild(String objectId) async {
    var list = [...state.requireValue.buildList];
    var netService = ref.watch(netProvider);
    await netService.delWebBuild(objectId);

    list.removeWhere((element) => element.netBuild.objectId == objectId);
    state = AsyncValue.data(state.requireValue.copyWith(buildList: list));
  }

  FutureOr<BuildShareVM> webModel2View(NetBuildBusinessModel netBuild) async {
    var repo = ref.read(repoProvider).requireValue;

    PersonBuild personBuild = netBuild.build;
    List<Skill?> skills = await repo.skill.readSome(netBuild.build.equipSkills);
    // List<Skill?> skills = netBuild.build.equipSkills
    //     .map((e) => e == null ? null : repo.cacheSkills[e])
    //     .toList();
    Stats skillsStats = Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0);
    for (var skill in skills) {
      if (skill != null) {
        skillsStats.add(skill.stats);
        // 添加武器伤害
        skillsStats.atk += skill.might!;
        // 对武器炼成后的技能需要考虑添加额外技能的属性，除武器外其他类型的技能暂不考虑
        if (skill.refineId != null) {
          Skill refine = await repo.skill.mustRead(skill.refineId!);
          skillsStats.add(refine.stats);
        }
      }
    }
    Stats stats = Stats.fromJson(Utils.calcStats(
      _person,
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
      person: _person,
      arenaScore: await repo.getArenaScoreByBuild(personBuild),
      netBuild: netBuild,
    );
  }
}
