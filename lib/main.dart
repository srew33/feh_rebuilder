import 'dart:io';
import 'package:feh_tool/dataService.dart';
import 'package:feh_tool/pages/heroDetail/bindings.dart';
import 'package:feh_tool/pages/home/bindings.dart';
import 'package:feh_tool/pages/home/subview/openSource.dart';
import 'package:feh_tool/pages/home/view.dart';
import 'package:feh_tool/pages/skillsBrowse/bindings.dart';
import 'package:feh_tool/translate.dart';
import 'package:feh_tool/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/heroDetail/view.dart';
import 'pages/skillsBrowse/view.dart';
import 'package:path/path.dart' as p;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blue, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();

  Directory appDir = GetPlatform.isMobile
      ? await getApplicationDocumentsDirectory()
      : Directory.current.absolute;

  Directory tempDir = GetPlatform.isMobile
      ? await getTemporaryDirectory()
      : Directory(p.join(Directory.current.absolute.path, "cache"));

  await compute(Utils.updateAssets, [appDir, tempDir]);

  await Utils.cleanCache(tempDir);

  await initServices(appDir, tempDir);

  runApp(MyApp());
}

Future<void> initServices(Directory appPath, Directory tempDir) async {
  Utils.debug('starting services ...');

  await Get.putAsync(
      () => DataService(appPath: appPath, tempDir: tempDir).init());
  Utils.debug('all services inited ...');
}

List<GetPage> pages = [
  GetPage(
    name: '/home',
    page: () => Home(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: "/heroDetail",
    page: () => HeroDetail(),
    binding: HeroDetailBinding(),
  ),
  GetPage(
    name: "/skillsBrowse",
    page: () => SkillsBrowse(),
    binding: SkillsBrowseBindings(),
  ),
  GetPage(
    name: "/openSource",
    page: () => OpenSource(),
  ),
  GetPage(
    name: "/openSourceDetail",
    page: () => OpenSourceDetail(),
  ),
];

// for flutter 2.5
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DataService dataService = Get.find<DataService>();
    return GetMaterialApp(
      // for flutter 2.5
      scrollBehavior: MyCustomScrollBehavior(),
      title: 'Feh_Rebuilder',
      initialRoute: "/home",
      getPages: pages,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // fontFamily: "NotoSansCJKsc",
      ),
      translations: Translation(),
      locale:
          dataService.languageDict[dataService.customBox.read("dataLanguage")],
      fallbackLocale: Locale('en', 'US'),
    );
  }
}
