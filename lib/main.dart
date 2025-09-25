import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/core/theme/theme_notifier.dart';
import 'app/router.dart';
import 'package:ppv_components/core/theme/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.dark().textTheme);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp.router(
      title: 'ERP',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: themeNotifier.themeMode, // listen to ThemeNotifier
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
