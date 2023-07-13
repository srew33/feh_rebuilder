import 'dart:async';

import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:sembast/sembast.dart';

class NoDataException implements Exception {
  String table;

  String tag;

  NoDataException(this.table, this.tag);

  @override
  String toString() {
    return '数据缺失，请检查数据源: $table - $tag';
  }
}

/// T: key类型, N: 源类型, M: cache类型
abstract class DataTable<T, N, M> {
  DataTable({
    required this.db,
  });

  Database db;

  StoreRef<T, N> get _table;

  bool get readOnly;

  final Map<T, M> _cache = {};

  M deserialize(T key, N source);

  bool _refreshed = false;

  Future<Map<T, N>> getAllRaw() async {
    return Map.fromEntries(
        (await _table.find(db)).map((e) => MapEntry(e.key, e.value)));
  }

  /// 返回数据表全部已序列化的数据，一般格式是IDTAG:VALUE
  /// [forceRefresh] bool 刷新缓存
  Future<Map<T, M>> getAll([bool forceRefresh = false]) async {
    if (forceRefresh || !_refreshed) {
      _cache.clear();

      for (var e in await _table.find(db)) {
        var d = deserialize(e.key, e.value);
        _cache[e.key] = d;
      }

      _refreshed = true;
      return _cache;
    } else {
      return _cache;
    }
  }

  FutureOr<M?> read(T key) async {
    var v = await _table.record(key).get(db);
    if (v == null) {
      return null;
    }
    return _cache.putIfAbsent(key, () => deserialize(key, v));
    // return await _table.record(key).get(db);
  }

  FutureOr<List<M?>> readSome(Iterable<T?> keys) async {
    List<M?> r = [];

    for (var e in keys) {
      if (e == null) {
        r.add(null);
      } else {
        r.add(await read(e));
      }
    }
    return r;
  }

  FutureOr<M> mustRead(T key) async {
    return _cache.putIfAbsentAsync(key, () async {
      var v = await _table.record(key).get(db);
      if (v == null) {
        throw NoDataException(_table.name, key.toString());
      }
      return deserialize(key, v);
    });
  }

  Future delete(T key) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
    _cache.remove(key);
    await _table.record(key).delete(db);
  }

  Future deleteSome(Iterable<T> keys) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }

    keys.map((e) => _cache.remove(e));
    await _table.records(keys).delete(db);
  }

  Future drop() async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
    await _table.drop(db);
  }

  Future putIfAbsent(T key, dynamic value) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }

    await _table.record(key).put(db, value, merge: true);
    _cache.putIfAbsent(key, () => deserialize(key, value));
  }

  Future addAll(Iterable<T> keys, List<N> values) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
    await _table.records(keys).put(db, values, merge: true);
    for (var i = 0; i < keys.length; i++) {
      _cache.putIfAbsent(
          keys.elementAt(i), () => deserialize(keys.elementAt(i), values[i]));
    }
  }
}

class PersonTable extends DataTable<String, Map<String, dynamic>, Person> {
  PersonTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("person");

  @override
  bool get readOnly => true;

  @override
  Person deserialize(String key, Map<String, dynamic> source) =>
      Person.fromJson(source);
}

class SkillTable extends DataTable<String, Map<String, dynamic>, Skill> {
  SkillTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("skill");

  @override
  bool get readOnly => true;

  @override
  Skill deserialize(String key, Map<String, dynamic> source) =>
      Skill.fromJson(source);
}

class WeaponTable extends DataTable<String, Map<String, dynamic>, WeaponType> {
  WeaponTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("weaponType");

  @override
  bool get readOnly => true;

  @override
  WeaponType deserialize(String key, Map<String, dynamic> source) =>
      WeaponType.fromJson(source);
}

class TranslationsTable
    extends DataTable<String, Map<String, dynamic>, Map<String, dynamic>> {
  TranslationsTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("translations");

  @override
  bool get readOnly => true;

  @override
  Map<String, dynamic> deserialize(String key, Map<String, dynamic> source) =>
      source;
}

class FavouritesTable extends DataTable<String, dynamic, PersonBuild> {
  FavouritesTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("favourites");

  @override
  bool get readOnly => false;

  @override
  PersonBuild deserialize(String key, source) =>
      PersonBuild.fromJson(key, source);

  // Future<void> delOne(String key) async {
  //   await _table.record(key).delete(db);
  // }

  // Future<void> drop() async {
  //   await drop();
  // }
}

class ArenaTeamTable extends DataTable<String, dynamic, List<String?>> {
  ArenaTeamTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("arenaTeam");

  @override
  bool get readOnly => false;

  @override
  List<String?> deserialize(String key, source) =>
      (source as List).cast<String?>();
}

class ConfigTable extends DataTable<String, dynamic, dynamic> {
  ConfigTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, List<String?>> get _table => StoreRef("config");

  @override
  bool get readOnly => false;

  @override
  dynamic deserialize(String key, source) => source;
}

class SkillSeriesTable extends DataTable<String, List, List> {
  SkillSeriesTable({required super.db});

  @override
  StoreRef<String, List> get _table => StoreRef("skillSeries");

  @override
  List deserialize(String key, List source) => source;

  @override
  bool get readOnly => true;
}
