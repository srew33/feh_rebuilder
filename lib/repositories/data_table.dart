import 'package:sembast/sembast.dart';

abstract class DataTable<T, N> {
  DataTable({
    required this.db,
  });

  Database db;

  StoreRef<T, N> get _table;

  bool get readOnly;

  Future<Map<T, N>> getAll() async {
    return Map.fromEntries(
        (await _table.find(db)).map((e) => MapEntry(e.key, e.value)));
  }

  Future<N?> read(T key) async {
    return await _table.record(key).get(db);
  }

  Future delete(T key) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
    await _table.record(key).delete(db);
  }

  Future deleteSome(Iterable<T> keys) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
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
  }

  Future addAll(Iterable<T> keys, List<N> values) async {
    if (readOnly) {
      throw UnsupportedError("${_table.name}是一个只读表");
    }
    await _table.records(keys).put(db, values, merge: true);
  }
}

class PersonTable extends DataTable<String, Map<String, dynamic>> {
  PersonTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("person");

  @override
  bool get readOnly => true;
}

class SkillTable extends DataTable<String, Map<String, dynamic>> {
  SkillTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("skill");

  @override
  bool get readOnly => true;
}

class WeaponTable extends DataTable<String, Map<String, dynamic>> {
  WeaponTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("weaponType");

  @override
  bool get readOnly => true;
}

class TranslationsTable extends DataTable<String, Map<String, dynamic>> {
  TranslationsTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("translations");

  @override
  bool get readOnly => true;
}

class FavouritesTable extends DataTable<String, dynamic> {
  FavouritesTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("favourites");

  @override
  bool get readOnly => false;

  // Future<void> delOne(String key) async {
  //   await _table.record(key).delete(db);
  // }

  // Future<void> drop() async {
  //   await drop();
  // }
}

class ArenaTeamTable extends DataTable<String, dynamic> {
  ArenaTeamTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, Map<String, dynamic>> get _table => StoreRef("arenaTeam");

  @override
  bool get readOnly => false;
}

class ConfigTable extends DataTable<String, dynamic> {
  ConfigTable({required Database db}) : super(db: db);

  @override
  StoreRef<String, List<String?>> get _table => StoreRef("config");

  @override
  bool get readOnly => false;
}
