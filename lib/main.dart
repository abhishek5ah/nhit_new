import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/core/theme/theme_notifier.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/features/organization/services/organization_service.dart'; // <-- ADD
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';
import 'app/router.dart';
import 'package:ppv_components/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  ApiService.initialize();
  await authService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => OrganizationsApiService()),
        ChangeNotifierProvider(create: (_) => OrganizationService()), 
      ],
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
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
