import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import 'package:campus_guardian/features/auth/screens/auth_gate.dart';
import 'package:campus_guardian/features/auth/screens/login_screen.dart';
import 'package:campus_guardian/features/auth/screens/signup_screen.dart';

// Knowledge Hub (Posts)
import 'package:campus_guardian/features/microtalks/models/post.dart';
import 'package:campus_guardian/features/microtalks/screens/add_post_screen.dart';
import 'package:campus_guardian/features/microtalks/screens/my_posts_screen.dart';
import 'package:campus_guardian/features/microtalks/screens/post_detail_screen.dart';
import 'package:campus_guardian/features/microtalks/screens/posts_feed_screen.dart';

// Mentorship
import 'package:campus_guardian/features/mentorship/models/mentor.dart';
import 'package:campus_guardian/features/mentorship/screens/give_feedback_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/my_sessions_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/session_booking_screen.dart';

// Profile
import 'package:campus_guardian/features/profile/screens/edit_mentor_profile_screen.dart';
import 'package:campus_guardian/features/profile/screens/edit_profile_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:campus_guardian/features/profile/screens/public_profile_screen.dart';

// Skill Exchange
import 'package:campus_guardian/features/skill_exchange/models/exchange_post.dart';
import 'package:campus_guardian/features/skill_exchange/screens/create_exchange_screen.dart';
import 'package:campus_guardian/features/skill_exchange/screens/edit_exchange_screen.dart';
import 'package:campus_guardian/features/skill_exchange/screens/skill_exchange_screen.dart';

// KnowledgeBot
import 'package:campus_guardian/features/knowledgebot/screens/chat_screen.dart';

// Chat
import 'package:campus_guardian/features/chat/screens/chat_inbox_screen.dart';
import 'package:campus_guardian/features/chat/screens/private_chat_screen.dart';

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
        type: BottomNavigationBarType.fixed, // Use 'fixed' for 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Mentors'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Sessions'),
          // --- NEW: MESSAGES ITEM ---
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/app/mentors')) return 1;
    if (location.startsWith('/app/sessions')) return 2;
    // --- NEW: MESSAGES LOGIC ---
    if (location.startsWith('/app/messages')) return 3;
    if (location.startsWith('/app/profile')) return 4;
    return 0; // Default to Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/app/dashboard'); break;
      case 1: context.go('/app/mentors'); break;
      case 2: context.go('/app/sessions'); break;
    // --- NEW: MESSAGES CASE ---
      case 3: context.go('/app/messages'); break;
      case 4: context.go('/app/profile'); break;
    }
  }
}

class AppRoutes {
  AppRoutes._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Top-level auth routes
      GoRoute(path: '/', builder: (context, state) => const AuthGate()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

      // The ShellRoute contains screens with the main bottom navigation bar
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
          ),
          GoRoute(
            path: '/app/sessions',
            builder: (context, state) => const MySessionsScreen(),
          ),
          // --- NEW: MESSAGES INBOX ROUTE ---
          GoRoute(
            path: '/app/messages',
            builder: (context, state) => const ChatInboxScreen(),
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // --- CONSOLIDATED SKILL EXCHANGE ROUTE ---
          GoRoute(
            path: '/app/skill-exchange',
            builder: (context, state) => const SkillExchangeScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateExchangeScreen(),
              ),
              GoRoute(
                path: ':postId/edit',
                builder: (context, state) {
                  final post = state.extra as ExchangePost;
                  return EditExchangeScreen(post: post);
                },
              ),
            ],
          ),
        ],
      ),

      // Other top-level routes (these will cover the whole screen)
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(), // KnowledgeBot
      ),
      // --- FIXED: PRIVATE CHAT ROUTE ---
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>;
          // Ensure you pass both receiverId and receiverName when navigating
          final receiverId = extra['receiverId'];
          final receiverName = extra['receiverName'];

          return PrivateChatScreen(
            chatId: chatId,
            receiverId: receiverId,
            receiverName: receiverName,
          );
        },
      ),
      GoRoute(
        path: '/app/posts',
        builder: (context, state) => const PostsFeedScreen(),
        routes: [
          GoRoute(path: 'add', builder: (context, state) => const AddPostScreen()),
          GoRoute(
            path: ':postId',
            builder: (context, state) {
              final post = state.extra as Post;
              return PostDetailScreen(post: post);
            },
          )
        ],
      ),
      GoRoute(
        path: '/app/my-posts',
        builder: (context, state) => const MyPostsScreen(),
      ),
      GoRoute(
        path: '/app/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return PublicProfileScreen(userId: userId);
        },
        routes: [
          GoRoute(
            path: 'book',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  final mentor = Mentor.fromFirestore(snapshot.data!);
                  return SessionBookingScreen(mentor: mentor);
                },
              );
            },
          )
        ],
      ),
      GoRoute(
        path: '/app/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/app/profile/edit-mentor',
        builder: (context, state) => const EditMentorProfileScreen(),
      ),
      GoRoute(
        path: '/app/sessions/:sessionId/feedback',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final isUserTheMentor = state.extra as bool;
          return GiveFeedbackScreen(sessionId: sessionId, isUserTheMentor: isUserTheMentor);
        },
      )
    ],
  );
}

// NOTE: The DashboardScreen widget is unchanged. It's included here because
// it was in your original file.

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
            icon: Icons.article,
            title: 'Knowledge Hub',
            subtitle: 'Read posts from mentors.',
            onTap: () => context.go('/app/posts'),
          ),
          _buildDashboardCard(
            context: context,
            icon: Icons.swap_horiz,
            title: 'Skill Exchange',
            subtitle: 'Offer help and earn "Wisdom Credits".',
            onTap: () => context.go('/app/skill-exchange'),
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
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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