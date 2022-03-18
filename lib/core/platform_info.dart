// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  bool get isDesktopOS {
    if (kIsWeb) {
      return false;
    }

    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  bool get isAppOS {
    if (kIsWeb) {
      return false;
    }
    return Platform.isIOS || Platform.isAndroid;
  }

  bool get isWeb {
    return kIsWeb;
  }

  PlatformType getCurrentPlatformType() {
    if (kIsWeb) {
      return PlatformType.Web;
    }

    if (Platform.isMacOS) {
      return PlatformType.MacOS;
    }

    if (Platform.isFuchsia) {
      return PlatformType.Fuchsia;
    }

    if (Platform.isLinux) {
      return PlatformType.Linux;
    }

    if (Platform.isWindows) {
      return PlatformType.Windows;
    }

    if (Platform.isIOS) {
      return PlatformType.iOS;
    }

    if (Platform.isAndroid) {
      return PlatformType.Android;
    }

    return PlatformType.Unknown;
  }
}

enum PlatformType {
  Web,
  iOS,
  Android,
  MacOS,
  Fuchsia,
  Linux,
  Windows,
  Unknown,
}
