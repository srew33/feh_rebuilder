// import 'package:feh_rebuilder/global/filters/filter.dart';
// import 'package:feh_rebuilder/models/person/person.dart';

// //   1: "火",
// //   2: "水",
// //   3: "风",
// //   4: "地",
// //   5: "光",
// //   6: "暗",
// //   7: "天",
// //   8: "理",
// final List<int> _legendaryKind = const [1, 2, 3, 4];
// final List<int> _mythicKind = const [5, 6, 7, 8];

// extension SimpleFilterFunctionExtension on FilterFunction {
//   SimpleValid get function {
//     switch (this) {
//       case FilterFunction.personIsLegend:
//         return (person) {
//           return person is Person &&
//               person.legendary?.kind == 1 &&
//               _legendaryKind.contains(person.legendary?.element);
//         };
//       case FilterFunction.personIsInfantry:
//         return (person) {
//           return person is Person && person.moveType! == 0;
//         };
//       case FilterFunction.personIsArmored:
//         return (person) {
//           return person is Person && person.moveType! == 1;
//         };
//       case FilterFunction.personIsCavalry:
//         return (person) {
//           return person is Person && person.moveType! == 2;
//         };
//       case FilterFunction.personIsFlying:
//         return (person) {
//           return person is Person && person.moveType! == 3;
//         };
//       case FilterFunction.personIsRefresher:
//         return (person) {
//           return person is Person && person.refresher!;
//         };
//       case FilterFunction.personIsResplendent:
//         return (person) {
//           return person is Person && person.resplendentHero!;
//         };
//       case FilterFunction.personIsHarmonic:
//         return (person) {
//           return person is Person && person.legendary?.kind == 3;
//         };
//       case FilterFunction.personIsDuo:
//         return (person) {
//           return person is Person && person.legendary?.kind == 2;
//         };
//       case FilterFunction.personIsMythic:
//         return (person) {
//           return person is Person &&
//               person.legendary?.kind == 1 &&
//               _mythicKind.contains(person.legendary?.element);
//         };
//     }
//   }
// }
