import 'package:campus_guardian/features/mentorship/models/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionHistoryCard extends StatelessWidget {
  final Session session;
  const SessionHistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final isUserTheMentor = session.mentorId == currentUserId;

    // Get the feedback and rating this user RECEIVED
    final feedback = isUserTheMentor ? session.menteeFeedback : session.mentorFeedback;
    final rating = isUserTheMentor ? session.menteeRating : session.mentorRating;
    final otherPerson = isUserTheMentor ? session.menteeName : session.mentorName;

    // Don't show anything if there's no feedback for this session
    if (feedback == null || feedback.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) => Icon(
                  index < (rating ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                )),
                const SizedBox(width: 10),
                Expanded(child: Text("Feedback from $otherPerson", style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Text('"${feedback}"', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}