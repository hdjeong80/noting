import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'repository/app_data.dart';
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
      home: FutureBuilder(
        future: gNotingDatabase.openDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // return FutureBuilder<double>(
            //     future: whenNotZero(
            //       Stream<double>.periodic(Duration(milliseconds: 100),
            //           (x) => MediaQuery.of(context).size.height),
            //     ),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            return FirstScreen();
            //   } else {
            //     return Material(
            //       child: Center(
            //         child: CircularProgressIndicator(),
            //       ),
            //     );
            //   }
            // });
          } else {
            return Material(
              child: Center(
                // child: CircularProgressIndicator(),
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

Future<double> whenNotZero(Stream<double> source) async {
  await for (double value in source) {
    if (value > 0) {
      return value;
    }
  }
}
