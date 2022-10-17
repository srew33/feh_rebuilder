// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class BaseShareModel {
  Map<String, dynamic>? acl;
  String? objectId;
  DateTime? updatedAt;
  DateTime? createdAt;
  BaseShareModel({
    this.acl,
    this.objectId,
    this.updatedAt,
    this.createdAt,
  });
}
