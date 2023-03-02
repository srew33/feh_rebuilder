// // ignore_for_file: public_member_api_docs, sort_constructors_first

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// import 'package:feh_rebuilder/pages/fav/body/first/model.dart';

// import 'uni_image.dart';

// class HeroAvatar extends StatelessWidget {
//   const HeroAvatar({
//     Key? key,
//     this.vm,
//   }) : super(key: key);
//   final PersonBuildVM? vm;

//   @override
//   Widget build(BuildContext context) {
//     if (vm == null) {
//       return Stack(
//         alignment: Alignment.center,
//         children: [
//           const UniImage(
//             path: "assets/static/Wdw_HeroTrial_V1.png",
//             height: 60,
//           ),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Text(
//                 "空位",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   foreground: Paint()
//                     ..style = PaintingStyle.stroke
//                     ..strokeWidth = 3
//                     ..color = Colors.black,
//                 ),
//               ),
//               const Text(
//                 "空位",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )
//             ],
//           )
//         ],
//       );
//     }
//     if ((vm?.merged ?? 0) < 10) {
//       return _Avatar(
//         vm: vm,
//       );
//     }

//     return _Avatar10(
//       vm: vm!,
//     );
//   }
// }

// class _Avatar extends StatelessWidget {
//   const _Avatar({
//     Key? key,
//     this.vm,
//   }) : super(key: key);

//   final PersonBuildVM? vm;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.center,
//       children: [
//         UniImage(
//           path: vm?.summonerSupport ?? false
//               ? "assets/static/Wdw_Reliance.png"
//               : "assets/static/Wdw_5.png",
//           height: 55,
//         ),
//         if (vm != null)
//           UniImage(
//             path: vm!.resplendent
//                 ? "assets/faces/${vm!.hero.faceName}EX01.webp"
//                 : "assets/faces/${vm!.hero.faceName}.webp",
//             height: 53,
//           ),
//         UniImage(
//           path: vm?.summonerSupport ?? false
//               ? "assets/static/Frm_Reliance.png"
//               : "assets/static/Frm_5.png",
//           height: 60,
//         ),
//       ],
//     );
//   }
// }

// class _Avatar10 extends StatelessWidget {
//   const _Avatar10({
//     Key? key,
//     required this.vm,
//   }) : super(key: key);

//   final PersonBuildVM vm;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.center,
//       children: [
//         UniImage(
//           path: vm.summonerSupport
//               ? "assets/static/Wdw_Reliance.png"
//               : "assets/static/Wdw_5.png",
//           height: 55,
//         ),
//         const UniImage(
//           path: "assets/static/Wdw2.png",
//           height: 55,
//         ),
//         UniImage(
//           path: vm.resplendent
//               ? "assets/faces/${vm.hero.faceName}EX01.webp"
//               : "assets/faces/${vm.hero.faceName}.webp",
//           height: 53,
//         ),
//         UniImage(
//           path: vm.summonerSupport
//               ? "assets/static/Frm_Reliance_10.png"
//               : "assets/static/Frm_5_10.png",
//           height: 60,
//         ),
//       ],
//     );
//   }
// }
