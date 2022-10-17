import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/build_share/favorite_table.dart';

abstract class BaseNetService {
  String? get currentUser;

  /// k:build的objectId,v:favourite
  Map<String, NetFavorite> get favourites;

  set favourites(Map<String, NetFavorite> value);

  bool get isInitialed;

  set isInitialed(bool value);

  Map<String, String> get tags;

  set tags(Map<String, String> value);

  Future<void> delWebBuild(NetBuild idTag);
  Future<List<NetBuild>> getWebBuilds(String idTag);

  Future initService();

  Future login();

  Future regist();

  Future restoreDevice(String oldDeviceId);

  Future uploadBuild(String idTag, List build, List<String>? tags);

  Future checkUpdate(int currentAppVersion, int currentDbVersion);

  Future starBuild(
    String? favId,
    String buildId,
    String likesId,
    int newType,
    int amount,
  );
}
