// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/repositories/net_service/cloud_object/build_table.dart';

import '../../utils.dart';

class PersonBuild extends Equatable {
  // 对应数据库中的key，是时间戳的字符串
  final String? key;
  final String personTag;
  final String? advantage;
  final String? disAdvantage;
  final int rarity;
  final int merged;
  final int dragonflowers;
  final bool resplendent;
  final bool summonerSupport;
  final List<String?> equipSkills;

  /// 弃用
  final int timeStamp;

  /// 弃用
  final bool custom;
  final String? ascendedAsset;
  final String tag;
  final String remark;

  const PersonBuild({
    this.key,
    required this.personTag,
    this.advantage,
    this.disAdvantage,
    this.rarity = 5,
    this.merged = 0,
    this.dragonflowers = 0,
    this.resplendent = false,
    this.summonerSupport = false,
    required this.equipSkills,
    this.timeStamp = 0,
    this.custom = false,
    this.ascendedAsset,
    this.tag = '',
    this.remark = '',
  });

  factory PersonBuild.fromJson(String? key, Map<String, dynamic> json) =>
      PersonBuild(
        key: key,
        personTag: json['id_tag'] as String,
        advantage: json['advantage'] as String?,
        disAdvantage: json['disAdvantage'] as String?,
        rarity: json['rarity'] as int,
        merged: json['merged'] as int,
        dragonflowers: json['dragonflowers'] as int,
        resplendent: json['resplendent'] as bool,
        custom: json['custom'] as bool? ?? false,
        summonerSupport: json['summoner_support'] as bool,
        timeStamp: json['time_stamp'] as int? ?? 0,
        equipSkills: (json['equip_skills'] as List<dynamic>).cast<String?>(),
        ascendedAsset: json['ascendedAsset'] as String?,
        tag: json['tag'] as String? ?? "",
        remark: json['remark'] as String? ?? "",
      );

  Map<String, dynamic> toJson() => {
        'id_tag': personTag,
        'advantage': advantage,
        'disAdvantage': disAdvantage,
        'rarity': rarity,
        'merged': merged,
        'dragonflowers': dragonflowers,
        'resplendent': resplendent,
        'summoner_support': summonerSupport,
        'equip_skills': equipSkills,
        "custom": custom,
        "time_stamp": timeStamp,
        'ascendedAsset': ascendedAsset,
        'tag': tag,
        'remark': remark,
      };

  @override
  List<Object?> get props {
    return [
      personTag,
      advantage,
      disAdvantage,
      rarity,
      merged,
      dragonflowers,
      resplendent,
      summonerSupport,
      equipSkills,
      ascendedAsset,
      tag,
    ];
  }

  List toNetBuild() {
    return [
      personTag,
      advantage == null ? null : Utils.statKeys.indexOf(advantage!),
      disAdvantage == null ? null : Utils.statKeys.indexOf(disAdvantage!),
      rarity,
      merged,
      dragonflowers,
      resplendent,
      summonerSupport,
      for (var s in equipSkills.sublist(0, 8)) s,
      ascendedAsset == null ? null : Utils.statKeys.indexOf(ascendedAsset!),
    ];
  }

  factory PersonBuild.fromNet(NetBuildPO net) {
    return PersonBuild(
      personTag: net.build[0],
      // 一开始把空的性格定义为9，1.3.0改为null，这里是为了兼容
      advantage: (net.build[1] == null || net.build[1] == 9)
          ? null
          : Utils.statKeys[net.build[1]],
      disAdvantage: (net.build[2] == null || net.build[2] == 9)
          ? null
          : Utils.statKeys[net.build[2]],
      rarity: net.build[3],
      merged: net.build[4],
      dragonflowers: net.build[5],
      resplendent: net.build[6],
      summonerSupport: net.build[7],
      equipSkills: net.build.sublist(8, 16).cast<String?>(),
      ascendedAsset: (net.build[16] == null || net.build[16] == 9)
          ? null
          : Utils.statKeys[net.build[16]],
    );
  }
}
