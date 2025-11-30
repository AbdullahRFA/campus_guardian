import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../../../services/database_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';
import '../models/mentor.dart';

class SessionBookingScreen extends StatefulWidget {
  final Mentor mentor;
  const SessionBookingScreen({super.key, required this.mentor});

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  final _topicController = TextEditingController();

  // NEW VARIABLES
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  bool _isBooking = false;
  bool _isLoadingSlots = false;
  List<String> _bookedSlotsForDate = []; // Stores slots taken by other students

  @override
  void initState() {
    super.initState();
    // Fetch slots for "Today" immediately when screen loads
    _fetchBookedSlotsForDate(_selectedDate);
  }

  // 1. Function to fetch unavailable slots from Firestore
  Future<void> _fetchBookedSlotsForDate(DateTime date) async {
    setState(() => _isLoadingSlots = true);

    // Format date to match your database format (YYYY-MM-DD)
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final booked = await DatabaseService().getBookedSlots(widget.mentor.id, dateString);

    if (mounted) {
      setState(() {
        _bookedSlotsForDate = booked;
        _isLoadingSlots = false;
        // If the currently selected slot is now found to be booked, deselect it
        if (_selectedSlot != null && _bookedSlotsForDate.contains(_selectedSlot)) {
          _selectedSlot = null;
        }
      });
    }
  }

  // 2. Date Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Cannot book past dates
      lastDate: DateTime.now().add(const Duration(days: 30)), // Book up to 30 days in advance
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset slot when date changes
      });
      _fetchBookedSlotsForDate(picked);
    }
  }

  // --- NEW HELPER: Check if a specific time slot has passed ---
  bool _isSlotInPast(String timeSlot) {
    final now = DateTime.now();

    // 1. Check if the selected date is "Today"
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    // If it's a future date, the slot hasn't passed yet.
    if (!isToday) return false;

    try {
      // 2. Parse the time string (e.g., "06:30 PM")
      // usage of 'hh:mm a' handles "06:30 PM" format
      final DateTime parsedTime = DateFormat('hh:mm a').parse(timeSlot);

      // 3. Create a full DateTime object for "Today" at that specific time
      final DateTime slotDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute
      );

      // 4. Compare with current time
      return slotDateTime.isBefore(now);
    } catch (e) {
      // If parsing fails, don't disable it to be safe, or handle error
      debugPrint("Error parsing time slot '$timeSlot': $e");
      return false;
    }
  }

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlot == null || _topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date, time slot, and enter a topic.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final menteeName = userDoc.data()?['fullName'] ?? 'A Student';

      // Format the date to string
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // --- SAFETY CHECK (Double check before writing) ---
      final currentBooked = await DatabaseService().getBookedSlots(widget.mentor.id, dateString);
      if (currentBooked.contains(_selectedSlot)) {
        throw Exception("This slot was just booked by someone else! Please choose another.");
      }
      // --------------------------------------------------

      await DatabaseService().bookSession(
        mentorId: widget.mentor.id,
        menteeId: currentUser.uid,
        mentorName: widget.mentor.name,
        menteeName: menteeName,
        sessionTime: _selectedSlot!,
        sessionTopic: _topicController.text.trim(),
        sessionDate: dateString,
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
          SnackBar(content: Text('Failed to book: ${e.toString().replaceAll("Exception:", "")}'), backgroundColor: Colors.red),
        );
        _fetchBookedSlotsForDate(_selectedDate);
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> timeSlots = widget.mentor.availableTimeSlots;
    final formattedDate = DateFormat.yMMMMEEEEd().format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are booking a session with:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(widget.mentor.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 32),

            // --- DATE PICKER SECTION ---
            Text('Select Date', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Icon(Icons.calendar_month, color: Colors.blue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Available Time Slots', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),

            // --- TIME SLOTS SECTION ---
            if (_isLoadingSlots)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (timeSlots.isEmpty)
              const Text('This mentor has no general availability set.')
            else
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: timeSlots.map((slot) {
                  // 1. Is it booked by someone else?
                  final isBooked = _bookedSlotsForDate.contains(slot);

                  // 2. Is it in the past (e.g., 5 PM when it's currently 6 PM)?
                  final isPast = _isSlotInPast(slot);

                  // Disable if either condition is true
                  final isDisabled = isBooked || isPast;

                  final isSelected = _selectedSlot == slot;

                  return ChoiceChip(
                    label: Text(
                        slot,
                        style: TextStyle(
                          color: isDisabled ? Colors.grey : (isSelected ? Colors.white : theme.primaryColor),
                          decoration: isDisabled ? TextDecoration.lineThrough : null,
                        )
                    ),
                    selected: isSelected,
                    // Disable selection logic
                    onSelected: isDisabled ? null : (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    },
                    selectedColor: theme.primaryColor,
                    disabledColor: Colors.grey[200], // Color for disabled slots
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
            Text('Discussion Topic', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            AppTextField(
              controller: _topicController,
              labelText: 'Enter Topic',
              hintText: 'e.g., Career Advice, Flutter Project Help',
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