import 'package:flutter/widgets.dart';

import 'package:feh_rebuilder/repositories/repository.dart';

/// 参考i18n_extension核心代码实现的一个简单的翻译组件
///
/// 主要为了实现数据翻译和系统界面语言的分离，在保持系统界面语言的情况下实现数据自定义显示
class MyI18nWidget extends StatefulWidget {
  const MyI18nWidget({
    Key? key,
    required this.child,
    required this.startLocale,
    required this.translationLoader,
  }) : super(key: key);
  final Widget child;
  final Locale startLocale;
  final TranslationLoader translationLoader;

  @override
  State<MyI18nWidget> createState() => _MyI18nWidgetState();

  static _MyI18nWidgetState of(BuildContext context) {
    _InheritedI18n? inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedI18n>();

    if (inherited == null) {
      throw Exception("Can't find the `MyI18nWidget` widget. ");
    }

    return inherited.data;
  }
}

class _MyI18nWidgetState extends State<MyI18nWidget> {
  set locale(Locale newLocale) {
    widget.translationLoader
        .load(newLocale)
        .then((value) => Repository.translationData = value);
    setState(() {});
  }

  void _rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    _rebuildAllChildren();
    return _InheritedI18n(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedI18n extends InheritedWidget {
  final _MyI18nWidgetState data;

  const _InheritedI18n({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedI18n old) => true;
}

abstract class TranslationLoader {
  Future<Map<String, String>> load(Locale newLocale);
}

class MyTranslationLoader extends TranslationLoader {
  final Repository repo;
  MyTranslationLoader({
    required this.repo,
  });
  @override
  Future<Map<String, String>> load(Locale newLocale) async {
    return await repo.loadTranslationData(newLocale);
  }
}
