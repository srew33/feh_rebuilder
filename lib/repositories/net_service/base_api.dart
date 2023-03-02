import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/build_share/favorite_table.dart';

abstract class BaseNetService {
  String? get currentUser;

  /// k:build的objectId,v:favourite
  Map<String, NetFavoriteBusinessModel> get favourites;

  set favourites(Map<String, NetFavoriteBusinessModel> value);

  bool get isInitialed;

  set isInitialed(bool value);

  Map<String, String> get tags;

  set tags(Map<String, String> value);

  Future checkUpdate(int currentAppVersion, int currentDbVersion);

  Future<void> delWebBuild(String objectId);

  Future<List<NetBuildBusinessModel>> getWebBuilds(String idTag);

  Future<BaseNetService> initService();

  Future login();

  Future regist();

  Future restoreDevice(String oldDeviceId);

  Future starBuild(
    String? favId,
    String buildId,
    String likesId,
    int newType,
    int amount,
  );

  Future uploadBuild(String idTag, List build, List<String>? tags);
}
