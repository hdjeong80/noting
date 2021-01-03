import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'repository/app_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppData())],
      child: App(),
    ),
  );
}
