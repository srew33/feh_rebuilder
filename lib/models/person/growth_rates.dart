class GrowthRates {
  int hp;
  int atk;
  int spd;
  int def;
  int res;

  GrowthRates({
    required this.hp,
    required this.atk,
    required this.spd,
    required this.def,
    required this.res,
  });

  factory GrowthRates.fromJson(Map<String, dynamic> json) => GrowthRates(
        hp: json['hp'] as int,
        atk: json['atk'] as int,
        spd: json['spd'] as int,
        def: json['def'] as int,
        res: json['res'] as int,
      );

  Map<String, int> toJson() => {
        'hp': hp,
        'atk': atk,
        'spd': spd,
        'def': def,
        'res': res,
      };
}
