import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/pages/login_page.dart';
import 'features/home/pages/home_page.dart';
import 'features/profile/pages/profile_setup_page.dart';
import 'features/splash/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '轻卡 AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/profile-setup': (context) => const ProfileSetupPage(),
        '/home': (context) => const HomePage(),
        '/diet/manual': (context) =>
            const PlaceholderRoutePage(title: '手动饮食记录'),
        '/diet/photo': (context) => const PlaceholderRoutePage(title: '饮食识别'),
        '/exercise/screenshot': (context) =>
            const PlaceholderRoutePage(title: '运动识别'),
      },
    );
  }
}

class PlaceholderRoutePage extends StatelessWidget {
  const PlaceholderRoutePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: Center(child: Text(title))),
    );
  }
}
