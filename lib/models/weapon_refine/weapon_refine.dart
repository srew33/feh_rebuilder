import 'give.dart';

class WeaponRefine {
  String? orig;
  String? refined;
  List<Give>? use;
  Give? give;

  WeaponRefine({this.orig, this.refined, this.use, this.give});

  factory WeaponRefine.fromJson(Map<String, dynamic> json) => WeaponRefine(
        orig: json['orig'] as String?,
        refined: json['refined'] as String?,
        use: (json['use'] as List<dynamic>?)
            ?.map((e) => Give.fromJson(e as Map<String, dynamic>))
            .toList(),
        give: json['give'] == null
            ? null
            : Give.fromJson(json['give'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'orig': orig,
        'refined': refined,
        'use': use?.map((e) => e.toJson()).toList(),
        'give': give?.toJson(),
      };
}
