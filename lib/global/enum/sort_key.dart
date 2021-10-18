enum SortKey {
  // idNum,
  roman,
  bst,
  stats,
  hp,
  atk,
  spd,
  def,
  res,
}

extension SortKeyExtension on SortKey {
  String get value {
    switch (this) {
      // case SortKey.idNum:
      //   return "序号";
      case SortKey.roman:
        return "罗马音";
      case SortKey.bst:
        return "白值(含死斗)";
      case SortKey.stats:
        return "白值(不含死斗)";
      case SortKey.hp:
        return "HP";
      case SortKey.atk:
        return "ATK";
      case SortKey.spd:
        return "SPD";
      case SortKey.def:
        return "DEF";
      case SortKey.res:
        return "RES";
    }
  }
}
