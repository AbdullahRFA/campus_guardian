import 'package:campus_guardian/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final dbService = DatabaseService();

    final bool isUserTheMentor = session.mentorId == currentUserId;
    final String otherPersonName = isUserTheMentor ? session.menteeName : session.mentorName;
    final String role = isUserTheMentor ? 'Mentee' : 'Mentor';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                label: Text(session.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: _getStatusColor(session.status),
              ),
            ),
            // --- NEW: Action Buttons ---
            if (session.status != 'cancelled' && session.status != 'completed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Mentor-specific "Confirm" button
                    if (isUserTheMentor && session.status == 'pending')
                      TextButton(
                        child: const Text('CONFIRM', style: TextStyle(color: Colors.green)),
                        onPressed: () => dbService.updateSessionStatus(session.id, 'confirmed'),
                      ),

                    // "Cancel" button for both roles
                    TextButton(
                      child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
                      onPressed: () => dbService.updateSessionStatus(session.id, 'cancelled'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}