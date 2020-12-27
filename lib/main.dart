import 'package:flutter/material.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'repository/app_data.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData())
      ],
      child: App(),
    ),
  );
}