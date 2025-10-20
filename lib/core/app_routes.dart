import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';
import 'package:campus_guardian/features/dashboard/screens/home_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// This is our main screen that holds the BottomNavigationBar
// It's the "shell" for our other screens.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // We get the current route to set the selected index of the nav bar
    int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child, // The child will be our actual screen (Dashboard, Mentors, Profile)
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

  // Helper method to determine the selected tab
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/mentors')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0; // Default to Dashboard
  }

  // Helper method for navigation
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/mentors');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}

class AppRoutes {
  AppRoutes._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // This ShellRoute wraps our main screens with the MainShell (which has the BottomNavBar)
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/mentors',
            builder: (context, state) => const MentorListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // The new route for the chat screen, placed outside the ShellRoute
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
}

// A simple dashboard screen to show in the shell
// Found at the bottom of lib/core/app_routes.dart
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        // We can add action buttons here later, like notifications
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context: context,
            icon: Icons.people_alt,
            title: 'Find a Mentor',
            subtitle: 'Connect with alumni & professors.',
            onTap: () {
              // We'll create this route in the next step
              // context.go('/find-mentor');
              print('Navigate to Find a Mentor');
            },
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.mic,
            title: 'Micro-Talks',
            subtitle: 'Listen to short knowledge sessions.',
            onTap: () {
              print('Navigate to Micro-Talks');
            },
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Skill Exchange',
            subtitle: 'Offer help and earn "Wisdom Credits".',
            onTap: () {
              print('Navigate to Skill Exchange');
            },
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.auto_awesome,
            title: 'JU KnowledgeBot',
            subtitle: 'Ask the AI assistant for help.',
            onTap: () {
              print('Navigate to KnowledgeBot');
            },
          ),
        ],
      ),
    );
  }

  // This is our reusable card builder function
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