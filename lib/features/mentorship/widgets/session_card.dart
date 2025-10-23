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
              // Disabled "Confirmed" button
              const TextButton(
                onPressed: null,
                child: Text('CONFIRMED', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'completed'),
                child: const Text('COMPLETE', style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => dbService.updateSessionStatus(session.id, 'cancelled'),
                child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        case 'cancelled':
          return const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: null,
                child: Text('CANCELLED', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        case 'completed':
          return const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: null,
                child: Text('SESSION COMPLETED', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        default:
          return const SizedBox.shrink();
      }
    }
    // --- Button Logic for the Mentee ---
    else {
      // Mentee can only cancel if the session is pending or confirmed
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
    }

    // Default to no buttons for other states
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final bool isUserTheMentor = session.mentorId == currentUserId;
    final String otherPersonName = isUserTheMentor ? session.menteeName : session.mentorName;
    final String role = isUserTheMentor ? 'Mentee' : 'Mentor';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
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
                label: Text(
                  session.status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                backgroundColor: _getStatusColor(session.status),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            _buildActionButtons(context, isUserTheMentor, session),
          ],
        ),
      ),
    );
  }
}