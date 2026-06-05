import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

class MoveMateApp extends StatelessWidget {
  const MoveMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoveMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}