import 'package:feh_rebuilder/models/build_share/base.dart';

class NetFavorite extends BaseShareModel {
  NetFavorite({
    required this.buildId,
    required this.user,
    required this.type,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });

  String buildId;
  String user;
  int type;

  // @override
  // void fromJson(Map<String, dynamic> json) {
  //   build = json["build"] != null
  //       ? BPointer.fromJson(json["build"], (json) => NetBuild.fromJson(json))
  //       : null;
  //   user = json["user"];
  //   type = json["type"];

  //   acl = ACL.fromJson(json["ACL"]);
  //   // ? [objectId] 是否应该允许覆盖？
  //   objectId = json["objectId"];
  //   createdAt = DateTime.tryParse(json["createdAt"] ?? "");
  //   updatedAt = DateTime.tryParse(json["updatedAt"] ?? "");
  // }

  // factory NetFavorite.fromJson(Map<String, dynamic> json) =>
  //     NetFavorite()..fromJson(json);

  // @override
  // String get tableName => "favorite";

  // @override
  // Map<String, dynamic> toJson() => {
  //       "user": user,
  //       "type": type,
  //       "build": build?.toJson(),
  //     };
}
