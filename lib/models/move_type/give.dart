class Give {
  int? resType;
  int? count;

  Give({this.resType, this.count});

  factory Give.fromJson(Map<String, dynamic> json) => Give(
        resType: json['res_type'] as int?,
        count: json['count'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'res_type': resType,
        'count': count,
      };
}
