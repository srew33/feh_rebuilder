import 'dart:async';

import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/build_share/favorite_table.dart';
import 'package:feh_rebuilder/repositories/net_service/base_api.dart';
import 'package:feh_rebuilder/repositories/net_service/cloud_object/update_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leancloud_storage/leancloud.dart';

final netProvider = Provider<NetService>((ref) {
  return NetService(ref);
});

class NetService implements BaseNetService {
  NetService(this.ref);

  ProviderRef<NetService> ref;

  @override
  bool isInitialed = false;

  @override
  Map<String, NetFavoriteBusinessModel> favourites = {};

  @override
  Map<String, String> tags = {};

  bool _isThrottling = false;

  @override
  late String currentUser;

  @override
  Future<List<NetUpdateInfoPO>?> checkUpdate(
      int currentAppVersion, int currentDbVersion) async {
    List<NetUpdateInfoPO>? r = await _intercept(
      () async {
        throw UnimplementedError();
      },
      false,
    );
    return r;
  }

  @override
  Future<void> delWebBuild(String objectId) async {
    throw UnimplementedError();
  }

  Future<String> generateDeviceId() async {
    throw UnimplementedError();
  }

  Future<List<String?>> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<List<NetBuildBusinessModel>> getWebBuilds(String idTag) async {
    throw UnimplementedError();
  }

  @override
  Future<NetService> initService() async {
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
  Future<List<LCObject>> starBuild(
    String? favId,
    String buildId,
    String likesId,
    int newType,
    int amount,
  ) async {
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
}
