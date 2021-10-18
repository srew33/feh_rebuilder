import 'dart:io';
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/pages/heroDetail/bindings.dart';
import 'package:feh_rebuilder/pages/home/bindings.dart';
import 'package:feh_rebuilder/pages/home/view.dart';
import 'package:feh_rebuilder/pages/skillsBrowse/bindings.dart';
import 'package:feh_rebuilder/translate.dart';
import 'package:feh_rebuilder/utils.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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

  runApp(const MyApp());
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
    page: () => const Home(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: "/heroDetail",
    page: () => const HeroDetail(),
    binding: HeroDetailBinding(),
  ),
  GetPage(
    name: "/skillsBrowse",
    page: () => const SkillsBrowse(),
    binding: SkillsBrowseBindings(),
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
  const MyApp({Key? key}) : super(key: key);

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
      fallbackLocale: const Locale("zh", "CN"),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 现在不需要支持其他语言的界面
      supportedLocales: const <Locale>[
        Locale("zh", "CN"),
        // Locale('en', 'US'),
        // Locale("ja", "JP"),
      ],
      onReady: () async {
        ///缓存头像和常用的图片，
        await for (FileSystemEntity img
            in Directory(p.join(dataService.appPath.path, "assets", "faces"))
                .list()) {
          await precacheImage(FileImage(File(img.path)), context);
        }
        await for (FileSystemEntity img
            in Directory(p.join(dataService.appPath.path, "assets", "move"))
                .list()) {
          await precacheImage(FileImage(File(img.path)), context,
              size: const Size(20, 20));
        }
        await for (FileSystemEntity img
            in Directory(p.join(dataService.appPath.path, "assets", "weapon"))
                .list()) {
          await precacheImage(FileImage(File(img.path)), context,
              size: const Size(23, 23));
        }
      },
    );
  }
}
