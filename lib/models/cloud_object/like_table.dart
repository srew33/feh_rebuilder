import 'package:cloud_db/cloud_db.dart';

class LikeTable extends BTable with BTablePostMixin, BTablePutMixin {
  LikeTable({
    this.count,
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
  int? count;
  @override
  void fromJson(Map<String, dynamic> json) {
    count = json["count"];
    acl = ACL.fromJson(json["ACL"]);
    // ? [objectId] 是否应该允许覆盖？
    objectId = json["objectId"];
    createdAt = DateTime.tryParse(json["createdAt"] ?? "");
    updatedAt = DateTime.tryParse(json["updatedAt"] ?? "");
  }

  factory LikeTable.fromJson(Map<String, dynamic> json) =>
      LikeTable()..fromJson(json);

  @override
  String get tableName => "likes";

  @override
  Map<String, dynamic> toJson() => {"count": count};

  Future<void> countChange(bool plus) async {
    await put({
      "count": {"__op": "Increment", "amount": plus ? 1 : -1}
    });
  }
}
