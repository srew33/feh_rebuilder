class SkillAccessory {
  String? idTag;
  String? nextSeal;
  String? prevSeal;
  int? ssCoin;
  int? ssBadgeType;
  int? ssBadge;
  int? ssGreatBadge;

  SkillAccessory({
    this.idTag,
    this.nextSeal,
    this.prevSeal,
    this.ssCoin,
    this.ssBadgeType,
    this.ssBadge,
    this.ssGreatBadge,
  });

  factory SkillAccessory.fromJson(Map<String, dynamic> json) => SkillAccessory(
        idTag: json['id_tag'] as String?,
        nextSeal: json['next_seal'] as String?,
        prevSeal: json['prev_seal'] as String?,
        ssCoin: json['ss_coin'] as int?,
        ssBadgeType: json['ss_badge_type'] as int?,
        ssBadge: json['ss_badge'] as int?,
        ssGreatBadge: json['ss_great_badge'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id_tag': idTag,
        'next_seal': nextSeal,
        'prev_seal': prevSeal,
        'ss_coin': ssCoin,
        'ss_badge_type': ssBadgeType,
        'ss_badge': ssBadge,
        'ss_great_badge': ssGreatBadge,
      };
}
