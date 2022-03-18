class Skills {
  late List<List<String?>> skills;
  static const List<String?> skillsList = [
    "weapon",
    "assist",
    "special",
    null,
    null,
    null,
    "weapon",
    "assist",
    "special",
    "passiveA",
    "passiveB",
    "passiveC",
    null,
    null
  ];

  ///传入1到5星技能列表，返回五星时的所有技能
  Skills(this.skills);

  factory Skills.fromJson(List<dynamic> json) {
    return Skills(
        (json).map((e) => (e as List<dynamic>).cast<String?>()).toList());
  }

  List<List<String?>> toJson() {
    return skills;
  }
}
