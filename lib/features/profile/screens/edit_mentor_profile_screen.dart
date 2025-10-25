import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditMentorProfileScreen extends StatefulWidget {
  const EditMentorProfileScreen({super.key});

  @override
  State<EditMentorProfileScreen> createState() => _EditMentorProfileScreenState();
}

class _EditMentorProfileScreenState extends State<EditMentorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  static const List<String> _allTimeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM', '08:00 PM', '08:30 PM',
    '09:00 PM', '09:30 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',

  ];

  final _mentorTitleController = TextEditingController();
  final _mentorBioController = TextEditingController();
  final _mentorExpertiseController = TextEditingController();
  bool _isMentorAvailable = false;
  List<String> _selectedSlots = [];

  @override
  void initState() {
    super.initState();
    _loadMentorData();
  }

  Future<void> _loadMentorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      // --- ADDED DEBUGGING PRINTS ---
      debugPrint("--- Loading Mentor Data ---");
      if (data == null) {
        debugPrint("Document data is null!");
      } else {
        debugPrint("Mentor Title from DB: ${data['mentorTitle']}");
        debugPrint("Is Available from DB: ${data['isMentorAvailable']}");
      }
      debugPrint("---------------------------");
      // --- END OF DEBUGGING ---
      if (data != null && mounted) {
        setState(() {
          _isMentorAvailable = data['isMentorAvailable'] ?? false;
          _mentorTitleController.text = data['mentorTitle'] ?? '';
          _mentorBioController.text = data['mentorBio'] ?? '';
          _mentorExpertiseController.text = (data['mentorExpertise'] as List<dynamic>? ?? []).join(', ');
          _selectedSlots = List<String>.from(data['availableTimeSlots'] ?? []);
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveMentorProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;

    List<String> expertiseList = _mentorExpertiseController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();

    Map<String, dynamic> mentorData = {
      'isMentorAvailable': _isMentorAvailable,
      'mentorTitle': _mentorTitleController.text.trim(),
      'mentorBio': _mentorBioController.text.trim(),
      'mentorExpertise': expertiseList,
      'availableTimeSlots': _selectedSlots,
    };

    try {
      await DatabaseService(uid: user.uid).updateUserProfile(mentorData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentor profile updated!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentorship Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
              // FIXED: Re-added the required properties to SwitchListTile
              child: SwitchListTile(
                title: const Text('Available for Mentorship', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_isMentorAvailable ? 'You will appear in mentor search results.' : 'You will not be listed as a mentor.'),
                value: _isMentorAvailable,
                onChanged: (bool value) {
                  setState(() {
                    _isMentorAvailable = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(controller: _mentorTitleController, labelText: 'Mentor Title', hintText: 'e.g., Software Engineer at Google'),
            const SizedBox(height: 16),
            AppTextField(controller: _mentorBioController, labelText: 'Mentor Bio', hintText: 'Describe your experience...', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _mentorExpertiseController, labelText: 'Areas of Expertise', hintText: 'e.g., Flutter, Career Advice'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text('Separate skills with a comma.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const Divider(height: 32),
            Text(
              'Set Your Available Time Slots',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _allTimeSlots.map((slot) {
                final isSelected = _selectedSlots.contains(slot);
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSlots.add(slot);
                      } else {
                        _selectedSlots.remove(slot);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            AppButton(text: 'Save Mentor Profile', onPressed: _saveMentorProfile),
          ],
        ),
      ),
    );
  }
}