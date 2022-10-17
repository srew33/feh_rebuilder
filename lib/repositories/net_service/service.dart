import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:crypto/crypto.dart';
import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/build_share/favorite_table.dart';
import 'package:feh_rebuilder/repositories/net_service/base_api.dart';
import 'package:feh_rebuilder/repositories/net_service/cloud_object/favorite_table.dart';
import 'package:feh_rebuilder/repositories/net_service/cloud_object/likes.dart';
import 'package:feh_rebuilder/repositories/net_service/cloud_object/tags.dart';
import 'package:feh_rebuilder/repositories/net_service/cloud_object/update_table.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'cloud_object/build_table.dart';

class NetService implements BaseNetService {
  @override
  bool isInitialed = false;

  @override
  Map<String, NetFavorite> favourites = {};

  @override
  Map<String, String> tags = {};

  bool _isThrottling = false;

  @override
  late String currentUser;

  @override
  Future<List<NetUpdateInfoPO>?> checkUpdate(
      int currentAppVersion, int currentDbVersion) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delWebBuild(NetBuild netBuild) async {
    throw UnimplementedError();
  }

  Future<String> generateDeviceId() async {
    throw UnimplementedError();
  }

  Future<List<String?>> getCurrentUser() async {
    var user = await LCUser.getCurrent();
    return [user?.username, user?.password];
  }

  @override
  Future<List<NetBuild>> getWebBuilds(String idTag) async {
    throw UnimplementedError();
  }

  @override
  Future<void> initService() async {
    throw UnimplementedError();
  }

  @override
  Future<LCUser> login() async {
    throw UnimplementedError();
  }

  @override
  Future regist() async {
    throw UnimplementedError();
  }

  @override
  Future restoreDevice(String oldDeviceId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> uploadBuild(String idTag, List build, List<String>? tags) async {
    throw UnimplementedError();
  }

  FutureOr<T?> _intercept<T>(FutureOr Function() task,
      [bool showToast = true]) async {
    throw UnimplementedError();
  }

  Future<void> _refreshCache() async {
    throw UnimplementedError();
  }

  @override
  Future<List<LCObject>> starBuild(
    String? favId,
    String buildId,
    String likesId,
    int newType,
    int amount,
  ) async {
    throw UnimplementedError();
  }
}
