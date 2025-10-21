import 'package:campus_guardian/features/auth/screens/auth_gate.dart';
import 'package:campus_guardian/features/auth/screens/login_screen.dart';
import 'package:campus_guardian/features/auth/screens/signup_screen.dart';
import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// (MainShell and DashboardScreen widgets remain the same as before...)
class MainShell extends StatelessWidget {
  // ... code for MainShell is unchanged
}

class AppRoutes {
  AppRoutes._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Auth Gate is now the entry point
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // The ShellRoute now has a different path
      ShellRoute(
        path: '/app', // Changed from '/'
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: 'dashboard', // This is now '/app/dashboard'
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'mentors', // This is now '/app/mentors'
            builder: (context, state) => const MentorListScreen(),
          ),
          GoRoute(
            path: 'profile', // This is now '/app/profile'
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
}

// (DashboardScreen widget and its _buildDashboardCard helper remain the same...)
class DashboardScreen extends StatelessWidget {
  // ... code for DashboardScreen is unchanged
}