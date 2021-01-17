import 'dart:io';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544~4354546703";
      return 'ca-app-pub-8802542115344603~6914455613';
    } else if (Platform.isIOS) {
      // return "ca-app-pub-3940256099942544~2594085930";
      return 'ca-app-pub-8802542115344603~5623417062';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544/8865242552";
      return 'ca-app-pub-8802542115344603/6326479860';
    } else if (Platform.isIOS) {
      // return "ca-app-pub-3940256099942544/4339318960";
      return 'ca-app-pub-8802542115344603/4745256148';
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
