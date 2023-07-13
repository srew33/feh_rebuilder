import 'package:feh_rebuilder/models/build_share/build_table.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'base.dart';

class NetBuildPO extends LCObject implements BaseNetModel {
  String get creator => this['creator'];
  set creator(String value) => this['creator'] = value;

  List get build => this['build'];
  set build(List value) => this['build'] = value;

  String get idTag => this['idTag'];
  set idTag(String value) => this['idTag'] = value;

  LCObject get likes => this['likes'];
  set likes(LCObject value) => this['likes'] = value;

  List<String> get tags => (this['tags'] as List).cast<String>();
  set tags(List<String> value) => this['tags'] = value;

  NetBuildPO() : super('builds');

  @override
  NetBuildBusinessModel toBusinessModel() {
    return NetBuildBusinessModel(
      creator: creator,
      build: PersonBuild.fromList(build),
      idTag: idTag,
      likesId: likes.objectId!,
      count: (likes["count"] is double)
          ? (likes["count"] as double).toInt()
          : likes["count"],
      tags: tags,
      // acl: jsonDecode(acl.toString()),
      objectId: objectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
