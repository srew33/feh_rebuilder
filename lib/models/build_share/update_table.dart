import 'package:feh_rebuilder/models/build_share/base.dart';

class UpdateTable extends BaseShareModel {
  UpdateTable({
    required this.id,
    required this.type,
    required this.info,
    required this.serverVersion,
    required this.minimalVersion,
    required this.alias,
    required this.url,
    required this.checksum,
    super.acl,
    super.createdAt,
    super.objectId,
    super.updatedAt,
  });
  int type;
  int id;
  String info;
  int serverVersion;
  int minimalVersion;
  String alias;
  String url;
  String checksum;

  // @override
  // void fromJson(Map<String, dynamic> json) {
  //   id = json["id"]!;
  //   type = json["type"]!;
  //   serverVersion = json["server_version"]!;
  //   minimalVersion = json["minimal_version"]!;
  //   info = json["info"] ?? "";
  //   alias = json["alias"] ?? "";
  //   url = json["url"] ?? "";
  //   checksum = json["checksum"] ?? "";
  // }

  // factory UpdateTable.fromJson(Map<String, dynamic> json) =>
  //     UpdateTable()..fromJson(json);

  // @override
  // String get tableName => "app_update_info";

  // @override
  // Map<String, dynamic> toJson() => {
  //       "id": id,
  //       "type": type,
  //       "server_version": serverVersion,
  //       "minimal_version": minimalVersion,
  //       "info": info,
  //       "alias": alias,
  //       "url": url,
  //       "checksum": checksum,
  //     };

  // @override
  // List<Object?> get props => [
  //       id,
  //       type,
  //       serverVersion,
  //       minimalVersion,
  //     ];
}
