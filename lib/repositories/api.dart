import 'dart:async';
import 'dart:convert';

import 'package:cloud_db/cloud_db.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/cloud_object/build_table.dart';
import 'package:feh_rebuilder/models/cloud_object/favorite_table.dart';
import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:feh_rebuilder/utils.dart';

class API {
  /// 网络服务初始化，不会初始化账号信息
  API() {
    if (EnvProvider.platformType == PlatformType.Android ||
        EnvProvider.platformType == PlatformType.Windows) {
      Cloud().init((err) => Utils.showToast(err.error.toString()));
    }
  }

  bool isThrottling = false;

  /// 网络tags
  Map<String, String> cloudTags = {};

  /// 网上的用户点赞的build
  Map<String, FavoriteTable> favorites = {};

  bool cacheRefreshed = false;

  /// 初始化/刷新用户和系统的一些必要的运行信息
  Future reFreshCache(bool allowGetId) async {
    if (!cacheRefreshed && allowGetId) {
      List results = await Future.wait([
        Query(table: "build_tags").doQuery(),
        Future<QueryResults>(() async {
          // 登录或以本机信息注册账号
          await Cloud().login();
          // 获取网上点赞的数据
          return await Query(table: "favorite", queryParameters: {
            "where": jsonEncode({"user": Cloud().currentUser.username})
          }).doQuery();
        }),
      ]);

      // 刷新网络的tags
      List<Map<String, dynamic>> tags = (results[0] as QueryResults).results;
      tags.sort((a, b) => (a["seq"] as int).compareTo(b["seq"] as int));
      for (var item in tags) {
        cloudTags.putIfAbsent(item["objectId"], () => item["value"]);
      }
      // 刷新网上点赞
      List<FavoriteTable> favs = ((results[1] as QueryResults).results)
          .map((e) => FavoriteTable.fromJson(e))
          .toList();
      favs.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      for (var item in favs) {
        favorites.putIfAbsent(item.build!.objectId, () => item);
      }

      cacheRefreshed = true;
    }
  }

  FutureOr<T?> _throttle<T>(FutureOr Function() task) async {
    if (isThrottling) {
      Utils.showToast("请等待上一个操作完成");
      return null;
    } else {
      isThrottling = true;
      try {
        T r = await task();
        return r;
      } on Exception catch (e) {
        Utils.debug(e.toString());
        return null;
      } finally {
        isThrottling = false;
      }
    }
  }

  Future<QueryResults?> query(
      String table, Map<String, dynamic>? queryParameters) async {
    return await _throttle<QueryResults>((() =>
        Query(table: table, queryParameters: queryParameters).doQuery()));
  }

  Future<List<BatchResult>?> doBatch(List<BatchTask> tasks) async {
    return await _throttle<List<BatchResult>>(
        (() => Batch(tasks: tasks).doTasks()));
  }

  Future<QueryResults?> getWebBuilds(String idTag) async {
    await Cloud().login();
    await reFreshCache(true);
    return await query(
      "hero_build",
      {
        "where": jsonEncode({"id_tag": idTag}),
        "include": "likes[count]",
      },
    );
  }

  Future<DeleteResult?> delWebBuild(HeroBuildTable data) async {
    return await _throttle<DeleteResult>((() => data.delete()));
  }

  Future<PostResult?> upload(
    String tag,
    String encodedBuild,
    List<String> tags,
  ) async {
    return await _throttle<PostResult>((() => HeroBuildTable(
          idTag: tag,
          tags: BArray(op: BArrayMethod.addUnique, objects: tags),
          creator: Cloud().currentUser.username,
          build: encodedBuild,
        ).create()));
  }
}
