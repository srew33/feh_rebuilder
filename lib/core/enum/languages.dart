import 'dart:ui' show Locale;

enum AppLanguages {
  zh,
  ja,
  en,
}

extension SysLanguagesExt on AppLanguages {
  Locale get locale {
    switch (this) {
      case AppLanguages.zh:
        return const Locale("zh", "TW");
      case AppLanguages.en:
        return const Locale("en", "US");
      case AppLanguages.ja:
        return const Locale("ja", "JP");
    }
  }

  Locale get localeWithoutCountry {
    switch (this) {
      case AppLanguages.zh:
        return const Locale("zh");
      case AppLanguages.en:
        return const Locale("en");
      case AppLanguages.ja:
        return const Locale("ja");
    }
  }
}
