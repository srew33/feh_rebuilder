// To parse this JSON data, do
//
//     final updateInfo = updateInfoFromJson(jsonString);

import 'dart:convert';

UpdateResp updateInfoFromJson(String str) =>
    UpdateResp.fromJson(json.decode(str));

String updateInfoToJson(UpdateResp data) => json.encode(data.toJson());

class UpdateResp {
  UpdateResp({
    this.results = const [],
  });

  List<UpdateInfo> results;

  factory UpdateResp.fromJson(Map<String, dynamic> json) => UpdateResp(
        results: json["results"] == null
            ? const []
            : List<UpdateInfo>.from(
                json["results"].map((x) => UpdateInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class UpdateInfo {
  UpdateInfo({
    this.alias,
    this.checksum,
    this.createdAt,
    required this.id,
    this.info,
    required this.minimalVersion,
    this.objectId,
    required this.serverVersion,
    required this.type,
    this.updatedAt,
    this.url,
  });
  String? alias;
  String? checksum;
  DateTime? createdAt;
  int id;
  String? info;
  int minimalVersion;
  String? objectId;
  int serverVersion;
  int type;
  DateTime? updatedAt;
  String? url;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        alias: json["alias"],
        checksum: json["checksum"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        id: json["id"],
        info: json["info"],
        minimalVersion: json["minimal_version"],
        objectId: json["objectId"],
        serverVersion: json["server_version"],
        type: json["type"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "alias": alias,
        "checksum": checksum,
        "createdAt": createdAt == null ? null : createdAt!.toIso8601String(),
        "id": id,
        "info": info,
        "objectId": objectId,
        "minimal_version": minimalVersion,
        "server_version": serverVersion,
        "type": type,
        "updatedAt": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "url": url,
      };
}
