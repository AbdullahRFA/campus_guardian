import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_guardian/features/auth/screens/auth_gate.dart';
import 'package:campus_guardian/features/auth/screens/login_screen.dart';
import 'package:campus_guardian/features/auth/screens/signup_screen.dart';
import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/profile/screens/edit_profile_screen.dart';
import '../features/mentorship/models/mentor.dart';
import '../features/mentorship/screens/mentor_detail_screen.dart';
import '../features/profile/screens/edit_mentor_profile_screen.dart';
import '../features/mentorship/screens/session_booking_screen.dart';
import '../features/mentorship/screens/my_sessions_screen.dart'; // NEW: Import the new screen

import 'package:campus_guardian/features/mentorship/screens/give_feedback_screen.dart';

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
        type: BottomNavigationBarType.fixed, // Ensures labels are always visible with 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mentors'),
          // NEW: Added the "Sessions" tab
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Sessions'),
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
    // NEW: Handle the index for the sessions tab
    if (location.startsWith('/app/sessions')) {
      return 2;
    }
    // UPDATED: Profile is now at index 3
    if (location.startsWith('/app/profile')) {
      return 3;
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
    // NEW: Handle navigation to the sessions screen
      case 2:
        context.go('/app/sessions');
        break;
    // UPDATED: Profile navigation is now case 3
      case 3:
        context.go('/app/profile');
        break;
    }
  }
}

class AppRoutes {
  AppRoutes._();

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
          GoRoute(
            path: '/app/mentors',
            builder: (context, state) => const MentorListScreen(),
            routes: [
              GoRoute(
                path: ':mentorId',
                builder: (context, state) {
                  final mentorId = state.pathParameters['mentorId']!;
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(mentorId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(body: Center(child: CircularProgressIndicator()));
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Scaffold(body: Center(child: Text('Mentor not found.')));
                      }
                      final mentor = Mentor.fromFirestore(snapshot.data!);
                      return MentorDetailScreen(mentor: mentor);
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (context, state) {
                      final mentorId = state.pathParameters['mentorId']!;
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(mentorId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Scaffold(body: Center(child: CircularProgressIndicator()));
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Scaffold(body: Center(child: Text('Mentor not found.')));
                          }
                          final mentor = Mentor.fromFirestore(snapshot.data!);
                          return SessionBookingScreen(mentor: mentor);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // NEW: Added the route for the "My Sessions" screen
          GoRoute(
              path: '/app/sessions',
              builder: (context, state) => const MySessionsScreen(),
              // ADD THIS NESTED ROUTE
              routes: [
                GoRoute(
                  path: ':sessionId/feedback', // e.g., /app/sessions/xyz/feedback
                  builder: (context, state) {
                    final sessionId = state.pathParameters['sessionId']!;
                    // We'll pass the user's role as an extra parameter
                    final isUserTheMentor = state.extra as bool;
                    return GiveFeedbackScreen(sessionId: sessionId, isUserTheMentor: isUserTheMentor);
                  },
                )
              ]
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'edit-mentor',
                builder: (context, state) => const EditMentorProfileScreen(),
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

// DashboardScreen class and its helper remain unchanged
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