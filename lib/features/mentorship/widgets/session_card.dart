import 'package:campus_guardian/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation
import '../models/session.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  const SessionCard({super.key, required this.session});

  // Helper to determine chip color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Builds the correct row of action buttons based on user role and session status.
  Widget _buildActionButtons(BuildContext context, bool isUserTheMentor, Session session) {
    final dbService = DatabaseService();

    // --- Button Logic for the Mentor ---
    if (isUserTheMentor) {
      switch (session.status) {
        case 'pending':
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('VIEW PROFILE'),
                onPressed: () => context.push('/app/profile/${session.menteeId}'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'confirmed'),
                child: const Text('CONFIRM', style: TextStyle(color: Colors.green)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'cancelled'),
                child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        case 'confirmed':
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'completed'),
                child: const Text('MARK AS COMPLETE', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'cancelled'),
                child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        case 'completed':
        // Show feedback button if the mentor has not given feedback yet
          if (session.mentorFeedback == null) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.go('/app/sessions/${session.id}/feedback', extra: true),
                  child: const Text('GIVE FEEDBACK', style: TextStyle(color: Colors.purple)),
                ),
              ],
            );
          }
          return const SizedBox.shrink(); // Hide button if feedback is already given
        default:
          return const SizedBox.shrink();
      }
    }
    // --- Button Logic for the Mentee ---
    else {
      if (session.status == 'pending' || session.status == 'confirmed') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => dbService.updateSessionStatus(session.id, 'cancelled'),
              child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      }
      if (session.status == 'completed') {
        // Show feedback button if the mentee has not given feedback yet
        if (session.menteeFeedback == null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.go('/app/sessions/${session.id}/feedback', extra: false),
                child: const Text('GIVE FEEDBACK', style: TextStyle(color: Colors.purple)),
              ),
            ],
          );
        }
      }
    }

    return const SizedBox.shrink(); // Default to no buttons for other states
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isUserTheMentor = session.mentorId == currentUserId;
    final otherPersonName = isUserTheMentor ? session.menteeName : session.mentorName;
    final role = isUserTheMentor ? 'Mentee' : 'Mentor';

    // NEW: Get the feedback and rating given BY the other person
    final feedbackReceived = isUserTheMentor ? session.menteeFeedback : session.mentorFeedback;
    final ratingReceived = isUserTheMentor ? session.menteeRating : session.mentorRating;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                child: Icon(isUserTheMentor ? Icons.person : Icons.school),
              ),
              title: Text('$otherPersonName ($role)', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Time: ${session.sessionTime} on ${session.sessionDate}'),
              trailing: Chip(
                label: Text(session.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                backgroundColor: _getStatusColor(session.status),
              ),
            ),

            // NEW: Show Topic, Feedback, and Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Topic: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: session.sessionTopic),
                      ],
                    ),
                  ),
                  // Only show feedback section if the session is completed
                  if (session.status == 'completed' && feedbackReceived != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < (ratingReceived ?? 0) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: Text('"$feedbackReceived"', style: const TextStyle(fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _buildActionButtons(context, isUserTheMentor, session),
          ],
        ),
      ),
    );
  }
}