import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'routes.dart';
import 'ui/first_screen.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Naver'),
      home: FirstScreen(),

      initialRoute: ScreenRoutes.initialRoute,
      routes: ScreenRoutes.routes,
    );
  }
}
