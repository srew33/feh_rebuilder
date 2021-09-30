import 'stats.dart';

class Legendary {
  String? duoSkillId;
  Stats? bonusEffect;
  int? kind;
  int? element;
  int? bst;
  bool? pairUp;
  bool? aeExtra;

  Legendary({
    this.duoSkillId,
    this.bonusEffect,
    this.kind,
    this.element,
    this.bst,
    this.pairUp,
    this.aeExtra,
  });

  factory Legendary.fromJson(Map<String, dynamic> json) => Legendary(
        duoSkillId: json['duo_skill_id'] as String?,
        bonusEffect: json['bonus_effect'] == null
            ? null
            : Stats.fromJson(json['bonus_effect'] as Map<String, dynamic>),
        kind: json['kind'] as int?,
        element: json['element'] as int?,
        bst: json['bst'] as int?,
        pairUp: json['pair_up'] as bool?,
        aeExtra: json['ae_extra'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'duo_skill_id': duoSkillId,
        'bonus_effect': bonusEffect?.toJson(),
        'kind': kind,
        'element': element,
        'bst': bst,
        'pair_up': pairUp,
        'ae_extra': aeExtra,
      };
}
