// ignore_for_file: constant_identifier_names

enum MoveTypeEnum {
  /// 步行
  Infantry,

  /// 重甲
  Armored,

  /// 骑马
  Cavalry,

  /// 飞行
  Flying,

  /// 全部
  All,
}

extension MoveTypeExtension on MoveTypeEnum {
  Set<int> get value {
    switch (this) {
      case MoveTypeEnum.All:
        return {0, 1, 2, 3};
      default:
        return {index};
    }
  }
}
