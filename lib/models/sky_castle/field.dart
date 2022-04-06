class Field {
  final String id;
  final int width;
  final int height;
  final int baseTerrain;
  final List<List<int>> terrain;
  Field({
    required this.id,
    required this.width,
    required this.height,
    required this.baseTerrain,
    required this.terrain,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'base_terrain': baseTerrain,
      'terrain': terrain,
    };
  }

  factory Field.fromJson(Map<String, dynamic> map) {
    return Field(
      id: map['id'] ?? '',
      width: map['width']?.toInt() ?? 0,
      height: map['height']?.toInt() ?? 0,
      baseTerrain: map['base_terrain']?.toInt() ?? 0,
      terrain: (map["terrain"] as List<dynamic>)
          .map((e) => (e as List<dynamic>).cast<int>())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Field(id: $id, width: $width, height: $height, base_terrain: $baseTerrain, terrain: $terrain)';
  }
}
