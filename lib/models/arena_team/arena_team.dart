// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ArenaTeam {
  final int createDateTime;
  final int updateDateTime;

  final List<String?> team;

  ArenaTeam({
    required this.createDateTime,
    required this.updateDateTime,
    required this.team,
  });

  ArenaTeam copyWith({
    int? createDateTime,
    int? updateDateTime,
    List<String?>? team,
  }) {
    return ArenaTeam(
      createDateTime: createDateTime ?? this.createDateTime,
      updateDateTime: updateDateTime ?? this.updateDateTime,
      team: team ?? this.team,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createDateTime': createDateTime,
      'updateDateTime': updateDateTime,
      'team': team,
    };
  }

  factory ArenaTeam.fromMap(Map<String, dynamic> map) {
    return ArenaTeam(
        createDateTime: map['createDateTime'] as int,
        updateDateTime: map['updateDateTime'] as int,
        team: List<String?>.from(
          (map['team'] as List<String?>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory ArenaTeam.fromJson(String source) =>
      ArenaTeam.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ArenaTeam(createDateTime: $createDateTime, updateDateTime: $updateDateTime, team: $team)';

  @override
  bool operator ==(covariant ArenaTeam other) {
    if (identical(this, other)) return true;

    return other.createDateTime == createDateTime &&
        other.updateDateTime == updateDateTime &&
        listEquals(other.team, team);
  }

  @override
  int get hashCode =>
      createDateTime.hashCode ^ updateDateTime.hashCode ^ team.hashCode;
}
