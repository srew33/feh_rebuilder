import 'package:cloud_db/cloud_db.dart';
import 'package:equatable/equatable.dart';

class UpdateTable extends BTable with EquatableMixin {
  UpdateTable({
    this.id,
    this.type,
    this.info,
    this.serverVersion,
    this.minimalVersion,
    this.alias,
    this.url,
    this.checksum,
    ACL? acl,
  }) : super(
          acl: acl ?? ACL(),
        );
  int? type;
  int? id;
  String? info;
  int? serverVersion;
  int? minimalVersion;
  String? alias;
  String? url;
  String? checksum;

  @override
  void fromJson(Map<String, dynamic> json) {
    id = json["id"]!;
    type = json["type"]!;
    serverVersion = json["server_version"]!;
    minimalVersion = json["minimal_version"]!;
    info = json["info"] ?? "";
    alias = json["alias"] ?? "";
    url = json["url"] ?? "";
    checksum = json["checksum"] ?? "";
  }

  factory UpdateTable.fromJson(Map<String, dynamic> json) =>
      UpdateTable()..fromJson(json);

  @override
  String get tableName => "app_update_info";

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "server_version": serverVersion,
        "minimal_version": minimalVersion,
        "info": info,
        "alias": alias,
        "url": url,
        "checksum": checksum,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        serverVersion,
        minimalVersion,
      ];
}
