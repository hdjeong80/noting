import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noting/repository/app_data.dart';
import 'package:noting/routes.dart';
import 'package:noting/ui/first_screen.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Naver'),
      home: FutureBuilder(
        future: gNotingDatabase.openDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FirstScreen();
          } else {
            return Material(
              child: Center(
                child: Container(),
              ),
            );
          }
        },
      ),
      initialRoute: ScreenRoutes.initialRoute,
      routes: ScreenRoutes.routes,
    );
  }
}
