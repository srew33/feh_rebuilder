import "package:feh_tool/models/person/stats.dart";

class JsonSkill {
  String? idTag;
  String? refineBase;
  String? nameId;
  String? descId;
  String? refineId;
  String? beastEffectId;
  List<String?> prerequisites;
  String? nextSkill;
  List<String?> sprites;
  Stats? stats;
  Stats? classParams;
  Stats? combatBuffs;
  Stats? skillParams;
  Stats? skillParams2;
  Stats? refineStats;
  int? idNum;
  int? sortId;
  int? iconId;
  int? wepEquip;
  int? movEquip;
  int? spCost;
  int? category;
  int? tomeClass;
  bool? exclusive;
  bool? enemyOnly;
  int? range;
  int? might;
  int? cooldownCount;
  bool? assistCd;
  bool? healing;
  int? skillRange;
  int? score;
  int? promotionTier;
  int? promotionRarity;
  bool? refined;
  int? refineSortId;
  int? wepEffective;
  int? movEffective;
  int? wepShield;
  int? movShield;
  int? wepWeakness;
  int? movWeakness;
  int? wepAdaptive;
  int? movAdaptive;
  int? timingId;
  int? abilityId;
  int? limit1Id;
  List<int> limit1Params;
  int? limit2Id;
  List<int> limit2Params;
  int? targetWep;
  int? targetMov;
  String? passiveNext;
  DateTime? timestamp;
  int? randomAllowed;
  int? minLv;
  int? maxLv;
  bool? ttInheritBase;
  int? randomMode;
  int? limit3Id;
  List<int> limit3Params;
  int? rangeShape;
  bool? targetEither;
  bool? distantCounter;
  int? cantoRange;
  int? pathfinderRange;

  JsonSkill({
    this.idTag,
    this.refineBase,
    this.nameId,
    this.descId,
    this.refineId,
    this.beastEffectId,
    this.prerequisites = const [null, null],
    this.nextSkill,
    this.sprites = const [null, null, null, null],
    this.stats,
    this.classParams,
    this.combatBuffs,
    this.skillParams,
    this.skillParams2,
    this.refineStats,
    this.idNum,
    this.sortId,
    this.iconId,
    this.wepEquip,
    this.movEquip,
    this.spCost,
    this.category,
    this.tomeClass,
    this.exclusive,
    this.enemyOnly,
    this.range,
    this.might,
    this.cooldownCount,
    this.assistCd,
    this.healing,
    this.skillRange,
    this.score,
    this.promotionTier,
    this.promotionRarity,
    this.refined,
    this.refineSortId,
    this.wepEffective,
    this.movEffective,
    this.wepShield,
    this.movShield,
    this.wepWeakness,
    this.movWeakness,
    this.wepAdaptive,
    this.movAdaptive,
    this.timingId,
    this.abilityId,
    this.limit1Id,
    this.limit1Params = const [0, 0],
    this.limit2Id,
    this.limit2Params = const [0, 0],
    this.targetWep,
    this.targetMov,
    this.passiveNext,
    this.timestamp,
    this.randomAllowed,
    this.minLv,
    this.maxLv,
    this.ttInheritBase,
    this.randomMode,
    this.limit3Id,
    this.limit3Params = const [0, 0],
    this.rangeShape,
    this.targetEither,
    this.distantCounter,
    this.cantoRange,
    this.pathfinderRange,
  });

  factory JsonSkill.fromJson(Map<String, dynamic> json) => JsonSkill(
        idTag: json['id_tag'] as String?,
        refineBase: json['refine_base'] as String?,
        nameId: json['name_id'] as String?,
        descId: json['desc_id'] as String?,
        refineId: json['refine_id'] as String?,
        beastEffectId: json['beast_effect_id'] as String?,
        prerequisites: json['prerequisites'] != null
            ? (json['prerequisites'] as List<dynamic>).cast<String?>()
            : [null, null],
        nextSkill: json['next_skill'] as String?,
        sprites: json['sprites'] != null
            ? (json['sprites'] as List<dynamic>).cast<String?>()
            : [null, null, null, null],
        stats: json['stats'] == null
            ? null
            : Stats.fromJson(json['stats'] as Map<String, dynamic>),
        classParams: json['class_params'] == null
            ? null
            : Stats.fromJson(json['class_params'] as Map<String, dynamic>),
        combatBuffs: json['combat_buffs'] == null
            ? null
            : Stats.fromJson(json['combat_buffs'] as Map<String, dynamic>),
        skillParams: json['skill_params'] == null
            ? null
            : Stats.fromJson(json['skill_params'] as Map<String, dynamic>),
        skillParams2: json['skill_params2'] == null
            ? null
            : Stats.fromJson(json['skill_params2'] as Map<String, dynamic>),
        refineStats: json['refine_stats'] == null
            ? null
            : Stats.fromJson(json['refine_stats'] as Map<String, dynamic>),
        idNum: json['id_num'] as int?,
        sortId: json['sort_id'] as int?,
        iconId: json['icon_id'] as int?,
        wepEquip: json['wep_equip'] as int?,
        movEquip: json['mov_equip'] as int?,
        spCost: json['sp_cost'] as int?,
        category: json['category'] as int?,
        tomeClass: json['tome_class'] as int?,
        exclusive: json['exclusive'] as bool?,
        enemyOnly: json['enemy_only'] as bool?,
        range: json['range'] as int?,
        might: json['might'] as int?,
        cooldownCount: json['cooldown_count'] as int?,
        assistCd: json['assist_cd'] as bool?,
        healing: json['healing'] as bool?,
        skillRange: json['skill_range'] as int?,
        score: json['score'] as int?,
        promotionTier: json['promotion_tier'] as int?,
        promotionRarity: json['promotion_rarity'] as int?,
        refined: json['refined'] as bool?,
        refineSortId: json['refine_sort_id'] as int?,
        wepEffective: json['wep_effective'] as int?,
        movEffective: json['mov_effective'] as int?,
        wepShield: json['wep_shield'] as int?,
        movShield: json['mov_shield'] as int?,
        wepWeakness: json['wep_weakness'] as int?,
        movWeakness: json['mov_weakness'] as int?,
        wepAdaptive: json['wep_adaptive'] as int?,
        movAdaptive: json['mov_adaptive'] as int?,
        timingId: json['timing_id'] as int?,
        abilityId: json['ability_id'] as int?,
        limit1Id: json['limit1_id'] as int?,
        limit1Params: json['limit1_params'] != null
            ? (json['limit1_params'] as List<dynamic>).cast<int>()
            : [0, 0],
        limit2Id: json['limit2_id'] as int?,
        limit2Params: json['limit2_params'] != null
            ? (json['limit1_params'] as List<dynamic>).cast<int>()
            : [0, 0],
        targetWep: json['target_wep'] as int?,
        targetMov: json['target_mov'] as int?,
        passiveNext: json['passive_next'] as String?,
        timestamp: json['timestamp'] == null
            ? null
            : DateTime.parse(json['timestamp'] as String),
        randomAllowed: json['random_allowed'] as int?,
        minLv: json['min_lv'] as int?,
        maxLv: json['max_lv'] as int?,
        ttInheritBase: json['tt_inherit_base'] as bool?,
        randomMode: json['random_mode'] as int?,
        limit3Id: json['limit3_id'] as int?,
        limit3Params: json['limit3_params'] != null
            ? (json['limit1_params'] as List<dynamic>).cast<int>()
            : [0, 0],
        rangeShape: json['range_shape'] as int?,
        targetEither: json['target_either'] as bool?,
        distantCounter: json['distant_counter'] as bool?,
        cantoRange: json['canto_range'] as int?,
        pathfinderRange: json['pathfinder_range'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id_tag': idTag,
        'refine_base': refineBase,
        'name_id': nameId,
        'desc_id': descId,
        'refine_id': refineId,
        'beast_effect_id': beastEffectId,
        'prerequisites': prerequisites,
        'next_skill': nextSkill,
        'sprites': sprites,
        'stats': stats?.toJson(),
        'class_params': classParams?.toJson(),
        'combat_buffs': combatBuffs?.toJson(),
        'skill_params': skillParams?.toJson(),
        'skill_params2': skillParams2?.toJson(),
        'refine_stats': refineStats?.toJson(),
        'id_num': idNum,
        'sort_id': sortId,
        'icon_id': iconId,
        'wep_equip': wepEquip,
        'mov_equip': movEquip,
        'sp_cost': spCost,
        'category': category,
        'tome_class': tomeClass,
        'exclusive': exclusive,
        'enemy_only': enemyOnly,
        'range': range,
        'might': might,
        'cooldown_count': cooldownCount,
        'assist_cd': assistCd,
        'healing': healing,
        'skill_range': skillRange,
        'score': score,
        'promotion_tier': promotionTier,
        'promotion_rarity': promotionRarity,
        'refined': refined,
        'refine_sort_id': refineSortId,
        'wep_effective': wepEffective,
        'mov_effective': movEffective,
        'wep_shield': wepShield,
        'mov_shield': movShield,
        'wep_weakness': wepWeakness,
        'mov_weakness': movWeakness,
        'wep_adaptive': wepAdaptive,
        'mov_adaptive': movAdaptive,
        'timing_id': timingId,
        'ability_id': abilityId,
        'limit1_id': limit1Id,
        'limit1_params': limit1Params,
        'limit2_id': limit2Id,
        'limit2_params': limit2Params,
        'target_wep': targetWep,
        'target_mov': targetMov,
        'passive_next': passiveNext,
        'timestamp': timestamp?.toIso8601String(),
        'random_allowed': randomAllowed,
        'min_lv': minLv,
        'max_lv': maxLv,
        'tt_inherit_base': ttInheritBase,
        'random_mode': randomMode,
        'limit3_id': limit3Id,
        'limit3_params': limit3Params,
        'range_shape': rangeShape,
        'target_either': targetEither,
        'distant_counter': distantCounter,
        'canto_range': cantoRange,
        'pathfinder_range': pathfinderRange,
      };
  @override
  String toString() {
    return idTag ?? "null";
  }
}
