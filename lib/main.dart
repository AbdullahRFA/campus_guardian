import 'package:campus_guardian/core/app_theme.dart';
import 'package:campus_guardian/core/app_routes.dart'; // <-- Import the routes
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load the .env file
  runApp(const MyApp());
}
// void main() {
//   runApp(const MyApp());
// }

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