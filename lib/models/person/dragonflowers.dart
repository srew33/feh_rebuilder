class Dragonflowers {
  int? maxCount;
  List<int>? costs;

  Dragonflowers({this.maxCount, required this.costs});

  factory Dragonflowers.fromJson(Map<String, dynamic> json) => Dragonflowers(
        maxCount: json['max_count'] as int?,
        // costs: (json['costs'] as List<dynamic>?).cast<int>(),
        costs: json['costs'] == null
            ? null
            : (json['costs'] as List<dynamic>).cast<int>(),
      );

  Map<String, dynamic> toJson() => {
        'max_count': maxCount,
        'costs': costs,
      };
}
