import 'package:campus_guardian/features/dashboard/screens/home_screen.dart';
import 'package:campus_guardian/features/mentorship/screens/mentor_list_screen.dart';
import 'package:campus_guardian/features/profile/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  // private constructor
  AppRoutes._();

  static final router = GoRouter(
    initialLocation: '/', // The route to show when the app starts
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
  );
}