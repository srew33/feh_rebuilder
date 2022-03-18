import 'dragonflowers.dart';
import 'growth_rates.dart';
import 'json_person.dart';
import 'legendary.dart';
import 'skills.dart';
import 'stats.dart';

class Person extends JsonPerson {
  int minRarity;
  int maxRarity;
  int type;
  bool? resplendentHero;
  int bst;
  bool recentlyUpdate;
  Stats? defaultStats;
  Map<String, String> translatedNames;

  Person({
    String? idTag,
    String? roman,
    String? faceName,
    String? faceName2,
    Legendary? legendary,
    Dragonflowers? dragonflowers,
    String? timestamp,
    int? idNum,
    int? versionNum,
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
    this.minRarity = 0,
    this.maxRarity = 0,
    this.resplendentHero = false,
    this.bst = 0,
    this.type = 0,
    this.recentlyUpdate = false,
    this.defaultStats,
    this.translatedNames = const {},
  }) : super(
          idTag: idTag,
          roman: roman,
          faceName: faceName,
          faceName2: faceName2,
          legendary: legendary,
          dragonflowers: dragonflowers,
          timestamp: timestamp,
          idNum: idNum,
          versionNum: versionNum,
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
        versionNum: json['version_num'] as int?,
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
        minRarity: json['min_rarity'] as int? ?? 0,
        maxRarity: json['max_rarity'] as int? ?? 0,
        type: json['type'] as int? ?? 0,
        resplendentHero: json["resplendent_hero"] as bool? ?? false,
        recentlyUpdate: json["recently_update"] as bool? ?? false,
        bst: json['bst'] as int? ?? 0,
        defaultStats: json['default_stats'] != null
            ? Stats.fromJson(json['default_stats'] as Map<String, dynamic>)
            : Stats(hp: 0, atk: 0, spd: 0, def: 0, res: 0),
        translatedNames:
            (json["translated_names"] as Map<String, dynamic>?) == null
                ? {}
                : (json["translated_names"] as Map<String, dynamic>)
                    .cast<String, String>(),
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
        'version_num': versionNum,
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
        "min_rarity": minRarity,
        "max_rarity": maxRarity,
        "resplendent_hero": resplendentHero,
        "recently_update": recentlyUpdate,
        "bst": bst,
        "type": type,
        "default_stats": defaultStats?.toJson(),
        "translated_names": translatedNames,
        // 'skills': skills?.map((e) => e.map((e) => e.map((e) => e.map((e) => e.map((e) => e.map((e) => e.toJson()).toList()).toList()).toList()).toList()).toList()).toList(),
      };

  @override
  String toString() {
    return idTag ?? "null";
  }
}
