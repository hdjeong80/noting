import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';

void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) {
    debugPrint("Native called background task: $taskName");

    final now = DateTime.now();
    return Future.wait<bool>([
      HomeWidget.saveWidgetData('title', 'Updated from Background'),
      HomeWidget.saveWidgetData('message',
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}'),
      HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample'),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
  InAppPurchaseConnection.enablePendingPurchases();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   statusBarIconBrightness: Brightness.light,
  //   statusBarBrightness:
  //       Platform.isAndroid ? Brightness.dark : Brightness.light,
  //   systemNavigationBarColor: Colors.black,
  //   systemNavigationBarDividerColor: Colors.grey,
  //   systemNavigationBarIconBrightness: Brightness.dark,
  // ));

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppData())],
      child: App(),
    ),
  );
}
