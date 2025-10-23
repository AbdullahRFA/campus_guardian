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
  String? _selectedSlot;
  bool _isBooking = false;

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlot == null) return;

    setState(() => _isBooking = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final menteeName = userDoc.data()?['fullName'] ?? 'A Student';

      await DatabaseService().bookSession(
        mentorId: widget.mentor.id,
        menteeId: currentUser.uid,
        mentorName: widget.mentor.name,
        menteeName: menteeName,
        sessionTime: _selectedSlot!,
      );

      if (mounted) {
        context.pop();
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
    // MODIFIED: Use the mentor's available slots, not a dummy list.
    final List<String> timeSlots = widget.mentor.availableTimeSlots;

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

            // MODIFIED: Handle the case where a mentor has no slots available.
            if (timeSlots.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('This mentor has not set any available times yet.'),
                ),
              )
            else
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                // MODIFIED: Map over the mentor's actual time slots.
                children: timeSlots.map((slot) {
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
          onPressed: _selectedSlot == null || _isBooking ? null : _handleConfirmBooking,
        ),
      ),
    );
  }
}