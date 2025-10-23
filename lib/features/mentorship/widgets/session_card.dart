import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/session.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Determine who the other person is
    final bool isUserTheMentor = session.mentorId == currentUserId;
    final String otherPersonName = isUserTheMentor ? session.menteeName : session.mentorName;
    final String role = isUserTheMentor ? 'Mentee' : 'Mentor';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          child: Icon(isUserTheMentor ? Icons.person : Icons.school),
        ),
        title: Text('$otherPersonName ($role)', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Time: ${session.sessionTime} on ${session.sessionDate}'),
        trailing: Chip(
          label: Text(session.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}