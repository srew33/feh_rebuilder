import 'package:feh_rebuilder/models/build_share/favorite_table.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'base.dart';

class NetFavouritePO extends LCObject implements BaseNetModel {
  String get user => this['user'];
  set user(String value) => this['user'] = value;

  LCObject get build => this['build'];
  set build(LCObject value) => this['build'] = value;

  int get type => this['type'];
  set type(int value) => this['type'] = value;

  NetFavouritePO() : super('favourite');

  @override
  NetFavoriteBusinessModel toBusinessModel() {
    return NetFavoriteBusinessModel(
      buildId: build.objectId!,
      user: user,
      type: type,
      // acl: acl.,
      createdAt: createdAt,
      updatedAt: updatedAt,
      objectId: objectId,
    );
  }
}
