import 'package:feh_tool/global/enum/moveType.dart';
import 'package:feh_tool/global/enum/series.dart';
import 'package:feh_tool/global/enum/weaponType.dart';
import 'package:feh_tool/global/filters/filter.dart';
import 'package:feh_tool/models/person/person.dart';

enum PersonFilterType {
  isRefersher,
  isResplendent,
  // 比翼
  isDuo,
  // 双界
  isHarmonic,
  // 传承
  isLegend,
  // 神阶
  isMythic,

  moveType,
  weaponType,
  series,
}

class PersonFilter implements Filter<Person, PersonFilterType> {
  List<Person> input = [];

  PersonFilterType filterType;

  dynamic valid;

  //   1: "火",
  //   2: "水",
  //   3: "风",
  //   4: "地",
  //   5: "光",
  //   6: "暗",
  //   7: "天",
  //   8: "理",
  final List<int> _legendaryKind = const [1, 2, 3, 4];
  final List<int> _mythicKind = const [5, 6, 7, 8];

  PersonFilter({required this.filterType, required this.valid});

  @override
  List<Person> get output {
    List<Person> _output = [];

    for (Person t in input) {
      if (filtFunc(t)) {
        _output.add(t);
      }
    }

    return _output;
  }

  @override
  bool filtFunc(person) {
    switch (filterType) {
      case PersonFilterType.isRefersher:
        return person.refresher!;
      case PersonFilterType.isResplendent:
        return person.resplendentHero!;
      case PersonFilterType.moveType:
        return (valid as Set<MoveTypeEnum>)
            .contains(MoveTypeEnum.values[person.moveType!]);
      case PersonFilterType.weaponType:
        return (valid as Set<WeaponTypeEnum>)
            .contains(WeaponTypeEnum.values[person.weaponType!]);
      case PersonFilterType.series:
        return (valid as Set<SeriesEnum>)
            .contains(SeriesEnum.values[person.series!]);
      case PersonFilterType.isDuo:
        return person.legendary?.kind == 2;
      case PersonFilterType.isMythic:
        return person.legendary?.kind == 1 &&
            _mythicKind.contains(person.legendary?.element);
      case PersonFilterType.isHarmonic:
        return person.legendary?.kind == 3;
      case PersonFilterType.isLegend:
        return person.legendary?.kind == 1 &&
            _legendaryKind.contains(person.legendary?.element);
      default:
        throw "错误的过滤类型";
    }
  }

  @override
  String toString() {
    return filterType.toString();
  }
}
