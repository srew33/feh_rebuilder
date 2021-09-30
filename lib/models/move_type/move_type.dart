class MoveType {
  String? idTag;
  int? index;
  int? range;

  MoveType({this.idTag, this.index, this.range});

  factory MoveType.fromJson(Map<String, dynamic> json) => MoveType(
        idTag: json['id_tag'] as String?,
        index: json['index'] as int?,
        range: json['range'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id_tag': idTag,
        'index': index,
        'range': range,
      };
}
