enum MoveTypeEnum {
  Infantry,
  Armored,
  Cavalry,
  Flying,
  All,
}

extension MoveTypeExtension on MoveTypeEnum {
  Set<int> get value {
    switch (this) {
      case MoveTypeEnum.All:
        return {0, 1, 2, 3};
      default:
        return {this.index};
    }
  }
}
