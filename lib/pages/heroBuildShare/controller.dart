import 'dart:convert';
import 'dart:io';

import 'package:cloud_db/cloud_db.dart';
import 'package:dio/dio.dart';
import 'package:feh_rebuilder/pages/home/subview/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/utils.dart';

class HeroBuildSharePageController extends GetxController {
  Person hero = Get.arguments as Person;

  final isLoading = true.obs;

  final List<HeroBuild> buildList = <HeroBuild>[].obs;

  // 节流应该可以做一个独立的全局装饰器
  bool isThrottling = false;

  Future throttle(Function f) async {
    if (!isThrottling) {
      try {
        isThrottling = true;
        await f();
      } finally {
        isThrottling = false;
      }
    } else {
      if (Platform.isWindows) {
        Utils.debug("请等待上一个操作结束");
      } else {
        Utils.showToast("请等待上一个操作结束");
      }
    }
  }

  Future delete(BuildContext context, String objectId) async {
    // if (!isThrottling) {
    bool? r = await showDialog<bool?>(
        context: context,
        builder: (context) => SimpleDialog(
              children: [
                const Text("确定要删除这条build吗？该操作不可恢复"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text(
                          "确定",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "取消",
                        )),
                  ],
                )
              ],
            ));
    if ((r ?? false)) {
      var _ = HeroBuildTable(objectId: objectId);
      isThrottling = true;
      try {
        await _.delete();

        Get.find<HeroBuildSharePageController>()
            .buildList
            .removeWhere((element) => element.tableData.objectId == objectId);
      } on DioError catch (e) {
        Utils.showToast("操作失败:${e.message}");
      }
    }
  }

  void addToFavorite(String encodedBuild) {
    if (!isThrottling) {
      isThrottling = true;
      try {
        var data = Get.find<DataService>();

        if (encodedBuild.isNotEmpty) {
          PersonBuild? _ = Utils.decodeBuild(encodedBuild, data);
          _?.custom = true;
          if (_ == null) {
            Utils.showToast("解析错误");
          } else {
            _.timeStamp = DateTime.now().millisecondsSinceEpoch;
            Iterable<Map<String, dynamic>>? values =
                (data.customBox.read("favorites") as Iterable<dynamic>?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];
            List<Map<String, dynamic>> favorites = values.toList();

            favorites.add(_.toJson());

            data.customBox.write("favorites", favorites);
          }
          Get.find<FavoritePageController>().refreshData();
          Utils.showToast("成功");
        }
      } finally {
        isThrottling = false;
      }
    } else {
      Utils.showToast("请等待执行完成");
    }
  }

  @override
  void onReady() async {
    await Cloud().login();
    if (!Get.find<DataService>().cacheRefreshed) {
      await Get.find<DataService>().refreshCache();
    }
    // await Cloud().sp.clear();
    QueryResults r = await Query(table: "hero_build", queryParameters: {
      "where": jsonEncode({"id_tag": hero.idTag}),
      "include": "likes[count]",
    }).doQuery();

    buildList.addAll([for (var item in r.results) HeroBuild.fromJson(item)]);

    isLoading.value = false;
    super.onReady();
  }
}

class HeroBuild {
  late final PersonBuild personBuild;
  late final Stats stats;
  late final Person person;
  late List<Skill?> skills;
  late HeroBuildTable tableData;

  HeroBuild({
    required this.personBuild,
    required this.stats,
    required this.person,
    required this.skills,
    required this.tableData,
  });

  factory HeroBuild.fromJson(Map<String, dynamic> json) {
    HeroBuildTable tableData = HeroBuildTable.fromJson(json);
    PersonBuild build =
        Utils.decodeBuild(tableData.build ?? "", Get.find<DataService>())!;
    Person person = Person.fromJson(
        Get.find<DataService>().personBox.read(build.personTag));
    List<Skill?> skills = [
      for (var item in build.equipSkills)
        item == null
            ? null
            : Skill.fromJson(Get.find<DataService>().skillBox.read(item))
    ];
    return HeroBuild(
        personBuild: build,
        stats: Stats.fromJson(Utils.calcStats(
          person,
          1,
          40,
          build.rarity,
          build.advantage,
          build.disAdvantage,
          build.merged,
          build.dragonflowers,
          build.resplendent,
          build.summonerSupport,
          build.ascendedAsset,
        )),
        skills: skills,
        tableData: tableData,
        person: person);
  }
}
