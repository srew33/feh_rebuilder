import 'package:equatable/equatable.dart';

class PersonBuild extends Equatable {
  final String personTag;
  final String? advantage;
  final String? disAdvantage;
  final int rarity;
  final int merged;
  final int dragonflowers;
  final bool resplendent;
  final bool summonerSupport;
  final List<String?> equipSkills;

  /// 竞技场分数，弃用
  final int arenaScore;

  /// 弃用
  final int timeStamp;

  /// 弃用
  final bool custom;
  final String? ascendedAsset;
  final String tag;
  final String remark;

  const PersonBuild({
    required this.personTag,
    this.advantage,
    this.disAdvantage,
    this.rarity = 5,
    this.merged = 0,
    this.dragonflowers = 0,
    this.resplendent = false,
    this.summonerSupport = false,
    required this.equipSkills,
    this.arenaScore = 0,
    this.timeStamp = 0,
    this.custom = false,
    this.ascendedAsset,
    this.tag = '',
    this.remark = '',
  });

  factory PersonBuild.fromJson(Map<String, dynamic> json) => PersonBuild(
        personTag: json['id_tag'] as String,
        advantage: json['advantage'] as String?,
        disAdvantage: json['disAdvantage'] as String?,
        rarity: json['rarity'] as int,
        merged: json['merged'] as int,
        dragonflowers: json['dragonflowers'] as int,
        resplendent: json['resplendent'] as bool,
        custom: json['custom'] as bool? ?? false,
        summonerSupport: json['summoner_support'] as bool,
        arenaScore: json['arena_score'] as int? ?? 0,
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
        "arena_score": arenaScore,
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
}
