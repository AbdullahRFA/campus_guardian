import 'package:campus_guardian/features/auth/screens/auth_gate.dart';
import 'package:campus_guardian/features/auth/screens/login_screen.dart';
import 'package:campus_guardian/features/auth/screens/signup_screen.dart';
import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/profile/screens/edit_profile_screen.dart';
import 'package:campus_guardian/features/mentorship/models/mentor.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_detail_screen.dart';

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

  // --- NEW: Dummy data for mentors, placed here to be accessible by the router ---
  static final List<Mentor> dummyMentors = const [
    const Mentor(
      id: '1',
      name: 'Dr. Md. Ezharul Islam',
      title: 'Professor',
      company: 'Jahangirnagar University',
      profileImageUrl: 'https://via.placeholder.com/150/1976D2/FFFFFF?text=EI',
      expertise: ['Machine Learning', 'AI', 'Research'],
    ),
    const Mentor(
      id: '2',
      name: 'Samsun Nahar Khandakar',
      title: 'Assistant Professor',
      company: 'Jahangirnagar University',
      profileImageUrl: 'https://via.placeholder.com/150/42A5F5/FFFFFF?text=SN',
      expertise: ['Data Structures', 'Algorithms', 'Web Dev'],
    ),
    const Mentor(
      id: '3',
      name: 'Ahsin Abid',
      title: 'Lead Engineer',
      company: 'Samsung Research',
      profileImageUrl: 'https://via.placeholder.com/150/0D47A1/FFFFFF?text=AA',
      expertise: ['Mobile Dev', 'Flutter', 'Career Growth'],
    ),
  ];

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
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
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/app/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          // --- MODIFIED: The /app/mentors route now has a nested route for details ---
          GoRoute(
            path: '/app/mentors',
            builder: (context, state) => MentorListScreen(mentors: dummyMentors), // Pass the data to the list screen
            routes: [
              GoRoute(
                path: ':mentorId', // This creates a dynamic path like /app/mentors/1
                builder: (context, state) {
                  // Find the mentor whose ID matches the one in the URL
                  final mentorId = state.pathParameters['mentorId']!;
                  final mentor = dummyMentors.firstWhere((m) => m.id == mentorId);
                  return MentorDetailScreen(mentor: mentor);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
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

// The main dashboard screen that users see on launch.
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
            onTap: () => context.go('/app/mentors'),
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