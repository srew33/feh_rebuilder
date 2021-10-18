// ignore_for_file: constant_identifier_names

enum WeaponTypeEnum {
  Sword,
  Lance,
  Axe,
  RedBow,
  BlueBow,
  GreenBow,
  ColorlessBow,
  RedDagger,
  BlueDagger,
  GreenDagger,
  ColorlessDagger,
  RedTome,
  BlueTome,
  GreenTome,
  ColorlessTome,
  Staff,
  RedBreath,
  BlueBreath,
  GreenBreath,
  ColorlessBreath,
  RedBeast,
  BlueBeast,
  GreenBeast,
  ColorlessBeast,

  /// 剑枪斧
  SLA,
  AllBow,
  AllDagger,
  AllTome,
  AllBreath,
  AllBeast,
  All
}

extension MoveTypeExtension on WeaponTypeEnum {
  Set<int> get value {
    switch (this) {
      case WeaponTypeEnum.All:
        return List.generate(24, (index) => index).toSet();
      case WeaponTypeEnum.SLA:
        return List.generate(3, (index) => index).toSet();
      case WeaponTypeEnum.AllBow:
        return List.generate(4, (index) => 3 + index).toSet();
      case WeaponTypeEnum.AllDagger:
        return List.generate(4, (index) => 7 + index).toSet();
      case WeaponTypeEnum.AllTome:
        return List.generate(4, (index) => 11 + index).toSet();
      case WeaponTypeEnum.AllBreath:
        return List.generate(4, (index) => 16 + index).toSet();
      case WeaponTypeEnum.AllBeast:
        return List.generate(4, (index) => 20 + index).toSet();
      default:
        return {index};
    }
  }

  int get groupIndex {
    switch (this) {
      // case WeaponTypeEnum.All:
      //   return List.generate(24, (index) => index).toSet();
      // case WeaponTypeEnum.SLA:
      //   return List.generate(3, (index) => index).toSet();
      case WeaponTypeEnum.AllBow:
        return 6;
      case WeaponTypeEnum.AllDagger:
        return 10;
      case WeaponTypeEnum.AllTome:
        return 14;
      case WeaponTypeEnum.AllBreath:
        return 19;
      case WeaponTypeEnum.AllBeast:
        return 23;
      default:
        return index;
    }
  }
}
