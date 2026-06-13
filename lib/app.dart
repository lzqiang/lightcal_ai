import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/pages/login_page.dart';
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
        '/home': (context) => const HomePlaceholderPage(),
      },
    );
  }
}

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('首页'))),
    );
  }
}
