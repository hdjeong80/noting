import 'package:flutter/material.dart';
import 'ui/first_screen.dart';
import 'ui/history_screen.dart';
class ScreenRoutes {
  static final home = '/';
  static final firstScreen = '/first_screen';
  static final historyScreen = '/history_screen';

  static final initialRoute = home;

  static final Map<String, WidgetBuilder> routes = {
    ScreenRoutes.firstScreen: (context) => FirstScreen(),
    ScreenRoutes.historyScreen: (context) => HistoryScreen(),
  };
}