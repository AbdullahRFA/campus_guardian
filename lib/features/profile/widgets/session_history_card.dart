import 'package:campus_guardian/features/mentorship/models/session.dart';
import 'package:flutter/material.dart';

class SessionHistoryCard extends StatelessWidget {
  final Session session;
  final String profileOwnerId; // The ID of the user whose profile is being viewed

  const SessionHistoryCard({
    super.key,
    required this.session,
    required this.profileOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the owner of THIS profile was the mentor in the session
    final bool wasProfileOwnerTheMentor = session.mentorId == profileOwnerId;

    // Get the feedback and rating the profile owner RECEIVED from the other person
    final feedback = wasProfileOwnerTheMentor ? session.menteeFeedback : session.mentorFeedback;
    final rating = wasProfileOwnerTheMentor ? session.menteeRating : session.mentorRating;

    // Get the name of the person who GAVE the feedback
    final feedbackGiverName = wasProfileOwnerTheMentor ? session.menteeName : session.mentorName;

    // Don't show anything if there's no feedback for this user in this session
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
                Expanded(child: Text("Feedback from $feedbackGiverName", style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Text('"$feedback"', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}