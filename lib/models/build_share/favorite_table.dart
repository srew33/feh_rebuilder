import 'package:cloud_db/cloud_db.dart';

import 'build_table.dart';

class FavoriteTable extends BTable {
  FavoriteTable({
    this.build,
    this.user,
    this.type,
    ACL? acl,
    String? objectId,
    DateTime? updatedAt,
    DateTime? createdAt,
    bool useDefaultAcl = false,
  }) : super(
          acl: acl ?? ACL(),
          objectId: objectId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          useDefaultAcl: useDefaultAcl,
        );
  BPointer<HeroBuildTable>? build;
  String? user;
  int? type;

  @override
  void fromJson(Map<String, dynamic> json) {
    build = json["build"] != null
        ? BPointer.fromJson(
            json["build"], (json) => HeroBuildTable.fromJson(json))
        : null;
    user = json["user"];
    type = json["type"];

    acl = ACL.fromJson(json["ACL"]);
    // ? [objectId] 是否应该允许覆盖？
    objectId = json["objectId"];
    createdAt = DateTime.tryParse(json["createdAt"] ?? "");
    updatedAt = DateTime.tryParse(json["updatedAt"] ?? "");
  }

  factory FavoriteTable.fromJson(Map<String, dynamic> json) =>
      FavoriteTable()..fromJson(json);

  @override
  String get tableName => "favorite";

  @override
  Map<String, dynamic> toJson() => {
        "user": user,
        "type": type,
        "build": build?.toJson(),
      };
}
