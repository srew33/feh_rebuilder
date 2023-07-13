import 'dart:async';
import 'dart:io';

import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/pages/fav/ui.dart';
import 'package:feh_rebuilder/pages/hero_detail/ui.dart';
import 'package:feh_rebuilder/pages/home/ui.dart';
import 'package:feh_rebuilder/pages/others/ui.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

void main() async {
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.blue, // status bar color
  // ));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EnvProvider.init();

  if (!kIsWeb) {
    // 清空缓存文件夹
    if (await Directory(EnvProvider.tempDir).exists()) {
      await Directory(EnvProvider.tempDir).delete(recursive: true);
    }
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    Utils.showToast(details.exceptionAsString());
  };

  runApp(
    ProviderScope(
        // observers: [Logger()],
        child: MaterialApp(
      title: 'feh_rebuilder',
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
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
        useMaterial3: true,
        // pageTransitionsTheme: const PageTransitionsTheme(builders: {
        //   TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        //   TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        // }),
        // fontFamily: "misans",
      ),
      builder: EasyLoading.init(),

      home: const App(),
    )),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  /// 启动时缓存头像和常用的图片，这样在首页列表滚动时会马上显示而不是延迟加载
  /// 根据设备性能不同，大约需要0.8到2秒才能加载完毕，目前没有在首页做加载动画
  Future<void> preloadAssets() async {
    // imageCache默认设置为1000张，100M，目前会稍微超一点，导致一些图片被清除出缓存
    // 这里修改到1500张，150M
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 1500;
    imageCache.maximumSizeBytes = 157286400;

    // windows下不生效
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "move")).list()) {
      precacheImage(FileImage(File(img.path)), context,
          size: const Size(20, 20));
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "weapon")).list()) {
      precacheImage(FileImage(File(img.path)), context,
          size: const Size(23, 23));
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "faces")).list()) {
      precacheImage(FileImage(File(img.path)), context);
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "static")).list()) {
      precacheImage(FileImage(File(img.path)), context);
    }
    await for (FileSystemEntity img
        in Directory(p.join(EnvProvider.rootDir, "assets", "skill_placeholder"))
            .list()) {
      precacheImage(FileImage(File(img.path)), context);
    }
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      Future(() => preloadAssets());
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repoProvider);

    return repo.when(
      error: (error, stackTrace) {
        FlutterNativeSplash.remove();
        return Center(
          child: Text(error.toString()),
        );
      },
      loading: () => Container(
        color: Colors.white,
      ),
      data: (data) {
        // FlutterNativeSplash.remove();
        return MyI18nWidget(
          initialLocale: ref.read(configProvider).dataLanguage.locale,
          translationLoader: data,
          child: const _HomePage(),
        );
      },
    );
  }
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

final homeIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class _HomePage extends ConsumerStatefulWidget {
  const _HomePage();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<_HomePage> {
  @override
  void initState() {
    super.initState();
    // 加载一个详情页并返回，加速后续页面显示速度
    Future(() async {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const HeroDetailPage(
              family: PersonBuild(
            personTag: "PID_アレス",
            equipSkills: [],
          )),
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Navigator.pop(context);
        }
        // 移除加载页面
        FlutterNativeSplash.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeIndexProvider);
    return IndexedStack(
      index: index,
      children: const [HomePage(), FavPage(), OthersPage()],
    );
  }
}
