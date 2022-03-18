import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/home_screens/cubit/screens_cubit.dart';
import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/home_screens/home/bloc/home_bloc.dart';
import 'package:feh_rebuilder/home_screens/page.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/repositories/api.dart';
import 'package:feh_rebuilder/repositories/config_cubit/config_cubit.dart';
import 'package:feh_rebuilder/repositories/data_provider.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart' as p;

import 'utils.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.blue, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await EnvProvider.init();
  if (!kIsWeb) {
    // 清空缓存文件夹
    if (await Directory(EnvProvider.tempDir).exists()) {
      await Directory(EnvProvider.tempDir).delete(recursive: true);
    }
  }
  Repository repo = await loadRepo();

  if (repo.gameDb.isFirstInitial) {
    // 尝试恢复老版本收藏数据
    await Utils.restoreOldVersionFavs(repo.favourites);
  }
  Config initialConfig = Config.fromJson(await repo.config.getAll());

  Repository.translationData =
      await repo.loadTranslationData(initialConfig.dataLanguage.locale);

  BlocOverrides.runZoned(
    () => runApp(MyApp(
      repo: repo,
      initialConfig: initialConfig,
    )),
    blocObserver: AppBlocObserver(),
  );
}

Future<Repository> loadRepo() async {
  GameDb gameDb = await loadDb();
  UserDb userDb = await UserDb(p.join(EnvProvider.rootDir, "user.db")).init();
  Repository repo = Repository(
    gameDb: gameDb,
    userDb: userDb,
  );
  await repo.initCaches();

  return repo;
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.repo,
    required this.initialConfig,
  }) : super(key: key);
  final Repository repo;
  final Config initialConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> preloadAssets() async {
    // 启动时缓存头像和常用的图片，这样在首页列表滚动时会马上显示而不是延迟加载
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "move")).list()) {
      await precacheImage(FileImage(File(img.path)), context,
          size: const Size(20, 20));
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "weapon")).list()) {
      await precacheImage(FileImage(File(img.path)), context,
          size: const Size(23, 23));
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "faces")).list()) {
      await precacheImage(FileImage(File(img.path)), context);
    }
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      preloadAssets().then((value) => null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => widget.repo,
        ),
        RepositoryProvider(
          create: (context) => API(),
          lazy: false,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConfigCubit(
              repo: widget.repo,
              initial: widget.initialConfig,
            ),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(repo: widget.repo)
              ..add(HomeStarted(
                  currentLang: context.read<ConfigCubit>().state.dataLanguage)),
          ),
          // 详情页收藏等操作需要查询FavscreenBloc，生成的页面和MyI18nWidget同级，
          // 直接使用context.read会读取不到，因此这里要放到MaterialApp上面
          BlocProvider<FavscreenBloc>(
            create: (context) =>
                FavscreenBloc(repo: widget.repo)..add(FavscreenStarted()),
          ),
        ],
        child: BlocBuilder<ConfigCubit, Config>(
          builder: (context, state) {
            return MaterialApp(
              title: 'feh_rebuilder',
              scrollBehavior: MyCustomScrollBehavior(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale("zh", "CN"),
                Locale("en", "US"),
                Locale("ja", "JP"),
                // Locale.fromSubtags(languageCode: "en"),
                // Locale.fromSubtags(languageCode: "ja"),
                // Locale.fromSubtags(languageCode: "zh"),
              ],
              // AppLanguages.values[state.dataLanguage.index].locale
              // locale: AppLanguages
              //     .values[state.dataLanguage.index].localeWithoutCountry,
              locale: const Locale("zh", "CN"),
              theme: ThemeData(
                primarySwatch: Colors.blue,
                // fontFamily: "misans",
              ),
              builder: EasyLoading.init(),
              home: MyI18nWidget(
                startLocale:
                    context.read<ConfigCubit>().state.dataLanguage.locale,
                translationLoader: MyTranslationLoader(repo: widget.repo),
                child: BlocProvider<ScreensCubit>(
                  create: (context) => ScreensCubit(),
                  child: const Screens(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<GameDb> loadDb() async {
  GameDb gameDb = await GameDb(p.join(EnvProvider.rootDir, "feh.db")).init();
  if (gameDb.db.version < EnvProvider.builtinDbVersion) {
    Utils.debug(
        "发现新版本 ${gameDb.db.version} -> ${EnvProvider.builtinDbVersion}");
    // 如果为真，表明是全新或更新安装
    if (EnvProvider.platformType == PlatformType.Android) {
      if (gameDb.db.version == 1) {
        Utils.debug("检测到首次启动");
        gameDb.isFirstInitial = true;
      }
      // 安卓环境，需要释放资源文件
      // windows自行解压
      var assets = await rootBundle.loadString("AssetManifest.json");

      Map<String, dynamic> d = jsonDecode(assets);

      for (var fileName in d.keys) {
        if (fileName.startsWith("assets")) {
          File f = File(p.join(EnvProvider.rootDir, fileName));
          await f.create(recursive: true);
          ByteData data = await rootBundle.load(fileName);
          await f.writeAsBytes(data.buffer.asUint8List());
        }
      }
      Utils.debug("释放资源文件完成");
    }

    Uint8List undecoded = kIsWeb
        ? (await rootBundle.load("assets/data.bin")).buffer.asUint8List()
        : await File(p.join(EnvProvider.rootDir, "assets", "data.bin"))
            .readAsBytes();

    final bytes = const ZLibDecoder().decodeBytes(undecoded);

    var data = jsonDecode(utf8.decode(bytes));

    await gameDb.updateDb(data);
  }
  return gameDb;
}

//  flutter 2.5 以上桌面平台默认没有拖动操作
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class AppBlocObserver extends BlocObserver {
  // @override
  // void onChange(BlocBase bloc, Change change) {
  //   super.onChange(bloc, change);
  //   print('${bloc.runtimeType} $change');
  // }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    Utils.showToast(error.toString());
    super.onError(bloc, error, stackTrace);
  }
}

/* @startuml
!theme plain
 start
 :EnvProvider.init() 获取环境变量;
 if(kisweb) then(no)
 :清空缓存文件夹;
 endif
 if(gameDb.db.version < EnvProvider.builtinDbVersion) then(yes)
 if(EnvProvider.platformType == PlatformType.Android) then(yes)
 :释放资源文件到assets文件夹;
 endif
 :读取assets/data.bin;
 :升级gamedb;
 :完成Repository初始化;
 :初始化config;
 :初始化I18n;
 :runApp;
 endif
 end
 @enduml
 */
