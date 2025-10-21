import 'package:campus_guardian/features/auth/screens/auth_gate.dart';
import 'package.campus_guardian/features/auth/screens/login_screen.dart';
import 'package.campus_guardian/features/auth/screens/signup_screen.dart';
import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package.go_router/go_router.dart';

// This is our main screen that holds the BottomNavigationBar and the FAB.
// It's the "shell" for our other screens.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat'),
        child: const Icon(Icons.auto_awesome),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mentors'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // MODIFIED: Helper method to determine the selected tab based on the new '/app' path
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/app/mentors')) {
      return 1;
    }
    if (location.startsWith('/app/profile')) {
      return 2;
    }
    return 0; // Default to Dashboard
  }

  // MODIFIED: Helper method for navigation to the new '/app' paths
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/app/dashboard');
        break;
      case 1:
        context.go('/app/mentors');
        break;
      case 2:
        context.go('/app/profile');
        break;
    }
  }
}

// Manages all the navigation routes for the application.
class AppRoutes {
  AppRoutes._();

  static final router = GoRouter(
    // The initial location is now the root, which will show the AuthGate.
    initialLocation: '/',
    routes: [
      // NEW: AuthGate is the new entry point of the app.
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      // NEW: Route for the Login screen.
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // NEW: Route for the Signup screen.
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // MODIFIED: The ShellRoute is now nested under the '/app' path.
      // This means a user must be authenticated to access these screens.
      ShellRoute(
        path: '/app',
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // MODIFIED: Routes inside the shell are now relative.
          GoRoute(
            path: 'dashboard', // Full path becomes /app/dashboard
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'mentors', // Full path becomes /app/mentors
            builder: (context, state) => const MentorListScreen(),
          ),
          GoRoute(
            path: 'profile', // Full path becomes /app/profile
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // UNCHANGED: The chat route is still a top-level route.
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
}

// The main dashboard screen that users see on launch.
// UNCHANGED: This widget's code does not need to be modified.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context: context,
            icon: Icons.people_alt,
            title: 'Find a Mentor',
            subtitle: 'Connect with alumni & professors.',
            onTap: () => context.go('/app/mentors'), // Go to the mentors screen
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.mic,
            title: 'Micro-Talks',
            subtitle: 'Listen to short knowledge sessions.',
            onTap: () => print('Navigate to Micro-Talks'),
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Skill Exchange',
            subtitle: 'Offer help and earn "Wisdom Credits".',
            onTap: () => print('Navigate to Skill Exchange'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}