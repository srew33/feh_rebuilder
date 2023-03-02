import 'dart:io';

import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/pages/fav/ui.dart';
import 'package:feh_rebuilder/pages/home/ui.dart';
import 'package:feh_rebuilder/pages/others/ui.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.blue, // status bar color
  ));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EnvProvider.init();
  if (!kIsWeb) {
    // 清空缓存文件夹
    if (await Directory(EnvProvider.tempDir).exists()) {
      await Directory(EnvProvider.tempDir).delete(recursive: true);
    }
  }

  runApp(ProviderScope(
    // observers: [Logger()],
    child: Consumer(
      builder: (context, ref, child) {
        final repo = ref.watch(repoProvider);
        return repo.when(
          error: (error, stackTrace) {
            FlutterNativeSplash.remove();
            return Container(
              color: Colors.white,
            );
          },
          loading: () => Container(
            color: Colors.white,
          ),
          data: (data) {
            FlutterNativeSplash.remove();
            return MyI18nWidget(
              initialLocale: ref.read(configProvider).dataLanguage.locale,
              translationLoader: data,
              child: const App(),
            );
          },
        );
      },
    ),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  Future<void> preloadAssets() async {
    // 启动时缓存头像和常用的图片，这样在首页列表滚动时会马上显示而不是延迟加载
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
    return MaterialApp(
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
          // primarySwatch: Colors.blue,
          // colorScheme: ColorScheme.highContrastLight(),
          // useMaterial3: true,
          // fontFamily: "misans",
          ),
      builder: EasyLoading.init(),
      home: Consumer(
        builder: (context, ref, child) {
          final index = ref.watch(homeIndexProvider);
          return IndexedStack(
            index: index,
            children: const [HomePage(), FavPage(), OthersPage()],
          );
        },
      ),
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

// class Logger extends ProviderObserver {
//   @override
//   void didAddProvider(
//       ProviderBase provider, Object? value, ProviderContainer container) {
//     super.didAddProvider(provider, value, container);
//     print("${provider.argument} created");
//   }

//   @override
//   void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
//     super.didDisposeProvider(provider, container);
//     print("${provider.argument} disposed");
//   }

// }
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
