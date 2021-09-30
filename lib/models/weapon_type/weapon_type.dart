class WeaponType {
  late String idTag;
  late int index;
  late int color;
  late int range;
  late int sortId;
  late int equipGroup;
  late bool resDamage;
  late bool isStaff;
  late bool isDagger;
  late bool isBreath;
  late bool isBeast;

  WeaponType({
    required this.idTag,
    required this.index,
    required this.color,
    required this.range,
    required this.sortId,
    required this.equipGroup,
    required this.resDamage,
    required this.isStaff,
    required this.isDagger,
    required this.isBreath,
    required this.isBeast,
  });

  factory WeaponType.fromJson(Map<String, dynamic> json) => WeaponType(
        idTag: json['id_tag'] as String,
        index: json['index'] as int,
        color: json['color'] as int,
        range: json['range'] as int,
        sortId: json['sort_id'] as int,
        equipGroup: json['equip_group'] as int,
        resDamage: json['res_damage'] as bool,
        isStaff: json['is_staff'] as bool,
        isDagger: json['is_dagger'] as bool,
        isBreath: json['is_breath'] as bool,
        isBeast: json['is_beast'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id_tag': idTag,
        'index': index,
        'color': color,
        'range': range,
        'sort_id': sortId,
        'equip_group': equipGroup,
        'res_damage': resDamage,
        'is_staff': isStaff,
        'is_dagger': isDagger,
        'is_breath': isBreath,
        'is_beast': isBeast,
      };
}
