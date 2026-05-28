import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(const NgstradamusApp());
}

class NgstradamusApp extends StatelessWidget {
  const NgstradamusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '농스트라다무스',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
