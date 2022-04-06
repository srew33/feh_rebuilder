// ignore_for_file: constant_identifier_names

enum PersonType {
  Normal,
  Grand_Hero_Battle,
  Special,
  Story,
  Legendary,
  Mythic,
  Tempest_Trials,
}

extension PersonTypeExtension on PersonType {
  String get name {
    switch (this) {
      case PersonType.Normal:
        return "普通召唤";
      case PersonType.Grand_Hero_Battle:
        return "大英雄战";
      case PersonType.Special:
        return "超英雄召唤";
      case PersonType.Story:
        return "剧情";
      case PersonType.Legendary:
        return "传承英雄召唤";
      case PersonType.Mythic:
        return "神阶英雄召唤";
      case PersonType.Tempest_Trials:
        return "战涡连战";
    }
  }
}
