// ignore_for_file: constant_identifier_names

enum SeriesEnum {
  Heroes,
  Mystery_of_the_Emblem,
  Shadows_of_Valentia,
  Genealogy_of_the_Holy_War,
  Thracia_776,
  The_Binding_Blade,
  The_Blazing_Blade,
  The_Sacred_Stones,
  Path_of_Radiance,
  Radiant_Dawn,
  Awakening,
  Fates,
  Three_Houses,
  FE_Encore
// Fire Emblem Heroes
// Fire Emblem: Mystery of the Emblem
// Fire Emblem: New Mystery of the Emblem (mixed in with Fire Emblem: Mystery of the Emblem and Fire Emblem: Shadow Dragon and the Blade of Light)
// Fire Emblem: Shadow Dragon and the Blade of Light (mixed in with Fire Emblem: Mystery of the Emblem)
// Fire Emblem Echoes: Shadows of Valentia
// Fire Emblem: Genealogy of the Holy War
// Fire Emblem: Thracia 776
// Fire Emblem: The Binding Blade
// Fire Emblem: The Blazing Blade
// Fire Emblem: The Sacred Stones
// Fire Emblem: Path of Radiance
// Fire Emblem: Radiant Dawn
// Fire Emblem Awakening
// Fire Emblem Fates
// Fire Emblem: Three Houses
// Tokyo Mirage Sessions ♯FE Encore
}

extension SeriesEnumExtension on SeriesEnum {
  String get name {
    switch (this) {
      case SeriesEnum.Heroes:
        return "火焰之纹章：英雄";
      case SeriesEnum.Mystery_of_the_Emblem:
        return "火焰之纹章：纹章之谜";
      case SeriesEnum.Shadows_of_Valentia:
        return "火焰之纹章回声：另一位英雄王";
      case SeriesEnum.Genealogy_of_the_Holy_War:
        return "火焰之纹章：圣战之系谱";
      case SeriesEnum.Thracia_776:
        return "火焰之纹章：多拉基亚776";
      case SeriesEnum.The_Binding_Blade:
        return "火焰之纹章：封印之剑";
      case SeriesEnum.The_Blazing_Blade:
        return "火焰之纹章：烈火之剑";
      case SeriesEnum.The_Sacred_Stones:
        return "火焰之纹章：圣魔之光石";
      case SeriesEnum.Path_of_Radiance:
        return "火焰之纹章：苍炎之轨迹";
      case SeriesEnum.Radiant_Dawn:
        return "火焰之纹章：晓之女神";
      case SeriesEnum.Awakening:
        return "火焰之纹章：觉醒";
      case SeriesEnum.Fates:
        return "火焰之纹章if";
      case SeriesEnum.Three_Houses:
        return "火焰之纹章：风花雪月";
      case SeriesEnum.FE_Encore:
        return "幻影异闻录";
    }
  }
}
