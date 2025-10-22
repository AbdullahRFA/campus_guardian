import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../models/mentor.dart';

class SessionBookingScreen extends StatefulWidget {
  final Mentor mentor;

  const SessionBookingScreen({super.key, required this.mentor});

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  // --- DUMMY DATA ---
  final List<String> _timeSlots = [
    '02:00 PM', '02:30 PM', '03:00 PM',
    '03:30 PM', '04:00 PM', '05:00 PM',
    '05:30 PM',
  ];
  // --- END DUMMY DATA ---

  String? _selectedSlot; // To keep track of the selected time

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
            // --- Mentor Info ---
            Text(
              'You are booking a session with:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.mentor.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),

            // --- Time Slot Selection ---
            Text(
              'Select an available time slot for today:',
              style: theme.textTheme.titleMedium,
            ),
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
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : theme.primaryColor,
                  ),
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
      // --- Confirmation Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        // The button is disabled until a time slot is selected
        child: AppButton(
          text: 'Confirm Booking',
          onPressed: _selectedSlot == null
              ? null
              : () {
            // We'll add real booking logic later
            print('Booking confirmed for ${widget.mentor.name} at $_selectedSlot');
            context.pop(); // Go back to the previous screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session booked successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}