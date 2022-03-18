class Stats {
  int hp;
  int atk;
  int spd;
  int def;
  int res;

  Stats({
    this.hp = 0,
    this.atk = 0,
    this.spd = 0,
    this.def = 0,
    this.res = 0,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        hp: json['hp'] as int,
        atk: json['atk'] as int,
        spd: json['spd'] as int,
        def: json['def'] as int,
        res: json['res'] as int,
      );

  Map<String, int> toJson() => {
        'hp': hp,
        'atk': atk,
        'spd': spd,
        'def': def,
        'res': res,
      };

  String toEffect() {
    String r = '';
    toJson().forEach((key, value) {
      if (value != 0) {
        r += "${key.toUpperCase()}+${value.toString()} ";
      }
    });
    return r;
  }

  int get sum {
    return hp + atk + spd + def + res;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  ///stats实例属性相加
  void add(dynamic val, {bool minus = false}) {
    // late Stats result;

    if (val is Stats) {
      if (minus) {
        hp -= val.hp;
        atk -= val.atk;
        spd -= val.spd;
        def -= val.def;
        res -= val.res;
      } else {
        hp += val.hp;
        atk += val.atk;
        spd += val.spd;
        def += val.def;
        res += val.res;
      }
      // result = Stats(
      //     hp: val.hp, atk: val.atk, spd: val.spd, def: val.def, res: val.res);
    } else if (val is Map) {
      add(Stats.fromJson(Map<String, int>.from(val)), minus: minus);
      // result = Stats.fromJson(Map<String, int>.from(val));
    } else if (val == null) {
    } else {
      throw "传入的类型需要是Stats或Map<String, int>，你传入的是${val.runtimeType}";
    }
    // result.hp += hp;
    // result.atk += atk;
    // result.spd += spd;
    // result.def += def;
    // result.res += res;
    // return result;
  }

  void clear() {
    hp = 0;
    atk = 0;
    spd = 0;
    def = 0;
    res = 0;
  }

  bool isZero() {
    if (hp != 0 || atk != 0 || spd != 0 || def != 0 || res != 0) {
      return false;
    } else {
      return true;
    }
  }
}
