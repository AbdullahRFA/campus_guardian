import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/database_service.dart';
import '../../../widgets/app_button.dart';
import '../models/mentor.dart';

class SessionBookingScreen extends StatefulWidget {
  final Mentor mentor;

  const SessionBookingScreen({super.key, required this.mentor});

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  final List<String> _timeSlots = [
    '02:00 PM', '02:30 PM', '03:00 PM',
    '03:30 PM', '04:00 PM', '05:00 PM',
    '05:30 PM',
  ];

  String? _selectedSlot;
  bool _isBooking = false;

  // --- NEW: Function to handle the booking logic ---
  Future<void> _handleConfirmBooking() async {
    if (_selectedSlot == null) return;

    setState(() => _isBooking = true);

    try {
      // 1. Get current user's details
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final menteeName = userDoc.data()?['fullName'] ?? 'A Student';

      // 2. Call the database service to create the session document
      await DatabaseService().bookSession(
        mentorId: widget.mentor.id,
        menteeId: currentUser.uid,
        mentorName: widget.mentor.name,
        menteeName: menteeName,
        sessionTime: _selectedSlot!,
      );

      if (mounted) {
        context.pop(); // Go back to the mentor detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session booked successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book session: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are booking a session with:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(widget.mentor.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Text('Select an available time slot for today:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSlot = selected ? slot : null;
                    });
                  },
                  labelStyle: TextStyle(color: isSelected ? Colors.white : theme.primaryColor),
                  selectedColor: theme.primaryColor,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: _isBooking ? 'Booking...' : 'Confirm Booking',
          // Disable button if no slot is selected or if booking is in progress
          onPressed: _selectedSlot == null || _isBooking ? null : _handleConfirmBooking,
        ),
      ),
    );
  }
}