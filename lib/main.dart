import 'package:campus_guardian/core/app_theme.dart';
import 'package:campus_guardian/core/app_routes.dart'; // <-- Import the routes
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Change MaterialApp to MaterialApp.router
    return MaterialApp.router(
      title: 'CampusGuardian',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Use the routerConfig property
      routerConfig: AppRoutes.router, // <-- Tell the app to use our router
    );
  }
}