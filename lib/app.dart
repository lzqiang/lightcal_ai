import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
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
        '/login': (context) => const LoginPlaceholderPage(),
      },
    );
  }
}

class LoginPlaceholderPage extends StatelessWidget {
  const LoginPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('登录页'),
        ),
      ),
    );
  }
}
