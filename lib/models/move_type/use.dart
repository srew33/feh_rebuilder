class Use {
  int? resType;
  int? count;

  Use({this.resType, this.count});

  factory Use.fromJson(Map<String, dynamic> json) => Use(
        resType: json['res_type'] as int?,
        count: json['count'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'res_type': resType,
        'count': count,
      };
}
