import 'package:campus_guardian/core/app_theme.dart';
import 'package:campus_guardian/core/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Firebase Core and the generated options file
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before any async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file for your Gemini API key
  await dotenv.load(fileName: ".env");

  // Initialize Firebase using the auto-generated options file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CampusGuardian',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}