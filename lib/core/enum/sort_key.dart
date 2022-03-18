enum SortKey {
  // idNum,
  translations,
  bst,
  stats,
  hp,
  atk,
  spd,
  def,
  res,
  versionNum,
}

extension SortKeyExtension on SortKey {
  String get transName {
    switch (this) {
      // case SortKey.idNum:
      //   return "序号";
      case SortKey.translations:
        return "罗马名/拼音";
      case SortKey.bst:
        return "白值(含死斗)";
      case SortKey.stats:
        return "白值(不含死斗)";
      case SortKey.hp:
        return "CUSTOM_STATS_HP";
      case SortKey.atk:
        return "CUSTOM_STATS_ATK";
      case SortKey.spd:
        return "CUSTOM_STATS_SPD";
      case SortKey.def:
        return "CUSTOM_STATS_DEF";
      case SortKey.res:
        return "CUSTOM_STATS_RES";
      case SortKey.versionNum:
        return "登场";
    }
  }
}
