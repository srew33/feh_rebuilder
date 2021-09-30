class ResplendentHero {
  int? idNum;
  DateTime? availStart;
  DateTime? availFinish;
  String? heroId;

  ResplendentHero({
    this.idNum,
    this.availStart,
    this.availFinish,
    this.heroId,
  });

  factory ResplendentHero.fromJson(Map<String, dynamic> json) =>
      ResplendentHero(
        idNum: json['id_num'] as int?,
        availStart: json['avail_start'] == null
            ? null
            : DateTime.parse(json['avail_start'] as String),
        availFinish: json['avail_finish'] == null
            ? null
            : DateTime.parse(json['avail_finish'] as String),
        heroId: json['hero_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id_num': idNum,
        'avail_start': availStart?.toIso8601String(),
        'avail_finish': availFinish?.toIso8601String(),
        'hero_id': heroId,
      };
}
