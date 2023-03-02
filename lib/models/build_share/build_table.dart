import 'package:feh_rebuilder/models/build_share/base.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';

class NetBuildBusinessModel extends BaseNetBusinessModel {
  NetBuildBusinessModel({
    required this.creator,
    required this.build,
    required this.idTag,
    required this.likesId,
    required this.tags,
    required this.count,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });
  String creator;
  PersonBuild build;
  String idTag;
  String likesId;
  List tags;

  /// 点赞数
  int count;
}
