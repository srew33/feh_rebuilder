import 'dart:convert';

import 'package:cloud_db/cloud_db.dart';

import 'like_table.dart';

class HeroBuildTable extends BTable {
  HeroBuildTable({
    this.creator,
    this.title,
    this.build,
    this.idTag,
    this.likes,
    // this.dislikes,
    this.tags,
    ACL? acl,
    String? objectId,
    DateTime? updatedAt,
    DateTime? createdAt,
    bool useDefaultAcl = true,
  }) : super(
          acl: acl ?? ACL(),
          objectId: objectId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          useDefaultAcl: useDefaultAcl,
        );
  String? creator;
  String? title;
  String? build;
  String? idTag;
  BPointer<LikeTable>? likes;
  // BPointer<DislikeTable>? dislikes;
  BArray<String>? tags;

  static const String table = "hero_build";

  @override
  String get tableName => table;

  @override
  Map<String, dynamic> toJson() {
    return {
      "creator": creator,
      "title": title,
      "build": build,
      "id_tag": idTag,
      "likes": likes?.toJson(),
      // "dislikes": dislikes?.toJson(),
      "tags": tags?.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  factory HeroBuildTable.fromJson(Map<String, dynamic> json) {
    return HeroBuildTable()..fromJson(json);
  }

  /// 新增一个build
  Future<PostResult> create() async {
    // var r = await Batch(tasks: [
    //   BatchTask(
    //     method: BatchMethod.POST,
    //     path: "/1/classes/likes",
    //     body: {"count": 0},
    //   ),
    //   BatchTask(
    //     method: BatchMethod.POST,
    //     path: "/1/classes/dislikes",
    //     body: {"count": 0},
    //   ),
    // ]).doTasks();
    var r = await LikeTable(count: 0).post();
    likes = BPointer(className: "likes", objectId: r.objectId!);
    // dislikes = BPointer(
    //     className: "dislikes", objectId: (r[1].result as PostResult).objectId!);
    var _r = await post();
    return _r;
  }

  /// 点赞/踩一个BUILD
  ///
  /// [isLike] 表示操作类型:1赞 2踩 0取消
  ///
  /// [isPlus]代表操作，true+1 false-1
  // Future likeBuild(int isLike, bool isPlus) async {
  //   if (objectId != null && likes != null) {
  //     var r = await Batch(tasks: [
  //       // favorite添加一条记录
  //       BatchTask(
  //         method: BatchMethod.POST,
  //         path: "/1/classes/favorite",
  //         body: {
  //           "user": Cloud().currentUser.username,
  //           "type": isLike,
  //           "build":
  //               BPointer(className: "hero_build", objectId: objectId!).toJson(),
  //         },
  //       ),
  //       // likes表+/-1
  //       BatchTask(
  //         method: BatchMethod.PUT,
  //         path: "/1/classes/likes/${likes!.objectId}",
  //         body: {
  //           "count": {"__op": "Increment", "amount": isPlus ? 1 : -1}
  //         },
  //       ),
  //     ]).doTasks();
  //   }
  // }

  @override
  void fromJson(Map<String, dynamic> json) {
    creator = json["creator"];
    title = json["title"];
    build = json["build"];
    idTag = json["id_tag"];

    likes = json["likes"] != null
        ? BPointer.fromJson(json["likes"], (json) => LikeTable.fromJson(json))
        : null;
    // dislikes = BPointer.fromJson(
    //     json["dislikes"], (json) => DislikeTable.fromJson(json));
    tags = BArray.fromJson((json["tags"] as List? ?? []).cast<String>());

    // 父属性
    acl = ACL.fromJson(json["ACL"]);
    // ? [objectId] 是否应该允许覆盖？
    objectId = json["objectId"];
    createdAt = DateTime.tryParse(json["createdAt"] ?? "");
    updatedAt = DateTime.tryParse(json["updatedAt"] ?? "");
  }
}
