import 'dragonflowers.dart';
import 'growth_rates.dart';
import 'json_person.dart';
import 'legendary.dart';
import 'skills.dart';
import 'stats.dart';

class Person extends JsonPerson {
  int? rarity;
  bool? resplendentHero;
  int bst;
  Stats? defaultStats;

  Person({
    String? idTag,
    String? roman,
    String? faceName,
    String? faceName2,
    Legendary? legendary,
    Dragonflowers? dragonflowers,
    String? timestamp,
    int? idNum,
    int? sortValue,
    int? origins,
    int? weaponType,
    int? tomeClass,
    int? moveType,
    int? series,
    bool? regularHero,
    bool? permanentHero,
    int? baseVectorId,
    bool? refresher,
    Stats? baseStats,
    GrowthRates? growthRates,
    Skills? skills,
    this.rarity = 5,
    this.resplendentHero = false,
    this.bst = 0,
    this.defaultStats,
  }) : super(
          idTag: idTag,
          roman: roman,
          faceName: faceName,
          faceName2: faceName2,
          legendary: legendary,
          dragonflowers: dragonflowers,
          timestamp: timestamp,
          idNum: idNum,
          sortValue: sortValue,
          origins: origins,
          weaponType: weaponType,
          tomeClass: tomeClass,
          moveType: moveType,
          series: series,
          regularHero: regularHero,
          permanentHero: permanentHero,
          baseVectorId: baseVectorId,
          refresher: refresher,
          baseStats: baseStats,
          growthRates: growthRates,
          skills: skills,
        );

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        idTag: json['id_tag'] as String?,
        roman: json['roman'] as String?,
        faceName: json['face_name'] as String?,
        faceName2: json['face_name2'] as String?,
        legendary: json['legendary'] == null
            ? null
            : Legendary.fromJson(json['legendary'] as Map<String, dynamic>),
        dragonflowers: json['dragonflowers'] == null
            ? null
            : Dragonflowers.fromJson(
                json['dragonflowers'] as Map<String, dynamic>),
        timestamp: json['timestamp'] as String?,
        idNum: json['id_num'] as int?,
        sortValue: json['sort_value'] as int?,
        origins: json['origins'] as int?,
        weaponType: json['weapon_type'] as int?,
        tomeClass: json['tome_class'] as int?,
        moveType: json['move_type'] as int?,
        series: json['series'] as int?,
        regularHero: json['regular_hero'] as bool?,
        permanentHero: json['permanent_hero'] as bool?,
        baseVectorId: json['base_vector_id'] as int?,
        refresher: json['refresher'] as bool?,
        baseStats: json['base_stats'] == null
            ? null
            : Stats.fromJson(json['base_stats'] as Map<String, dynamic>),
        growthRates: json['growth_rates'] == null
            ? null
            : GrowthRates.fromJson(
                json['growth_rates'] as Map<String, dynamic>),
        skills: Skills.fromJson(json["skills"]),
        rarity: json['rarity'] as int? ?? 3,
        resplendentHero: json["resplendent_hero"] as bool? ?? false,
        bst: json['bst'] as int? ?? 0,
        defaultStats: json['default_stats'] != null
            ? Stats.fromJson(json['default_stats'] as Map<String, dynamic>)
            : Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id_tag': idTag,
        'roman': roman,
        'face_name': faceName,
        'face_name2': faceName2,
        'legendary': legendary?.toJson(),
        'dragonflowers': dragonflowers?.toJson(),
        'timestamp': timestamp,
        'id_num': idNum,
        'sort_value': sortValue,
        'origins': origins,
        'weapon_type': weaponType,
        'tome_class': tomeClass,
        'move_type': moveType,
        'series': series,
        'regular_hero': regularHero,
        'permanent_hero': permanentHero,
        'base_vector_id': baseVectorId,
        'refresher': refresher,
        'base_stats': baseStats?.toJson(),
        'growth_rates': growthRates?.toJson(),
        'skills': skills?.toJson(),
        "rarity": rarity,
        "resplendent_hero": resplendentHero,
        "bst": bst,
        "default_stats": defaultStats?.toJson(),
        // 'skills': skills?.map((e) => e.map((e) => e.map((e) => e.map((e) => e.map((e) => e.map((e) => e.toJson()).toList()).toList()).toList()).toList()).toList()).toList(),
      };

  @override
  String toString() {
    return idTag ?? "null";
  }
}
