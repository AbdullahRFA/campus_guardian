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

  // Controllers for mentor-specific fields
  final _mentorTitleController = TextEditingController();
  final _mentorBioController = TextEditingController();
  final _mentorExpertiseController = TextEditingController();

  // State for the availability switch
  bool _isMentorAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadMentorData();
  }

  // Fetch existing mentor data to populate the form
  Future<void> _loadMentorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _isMentorAvailable = data['isMentorAvailable'] ?? false;
          _mentorTitleController.text = data['mentorTitle'] ?? '';
          _mentorBioController.text = data['mentorBio'] ?? '';
          // Join the list of expertise into a single string for the text field
          _mentorExpertiseController.text = (data['mentorExpertise'] as List<dynamic>? ?? []).join(', ');
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveMentorProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;

    // Convert the comma-separated string back into a list
    List<String> expertiseList = _mentorExpertiseController.text.split(',').map((e) => e.trim()).toList();

    Map<String, dynamic> mentorData = {
      'isMentorAvailable': _isMentorAvailable,
      'mentorTitle': _mentorTitleController.text.trim(),
      'mentorBio': _mentorBioController.text.trim(),
      'mentorExpertise': expertiseList,
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
            // --- Availability Switch ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
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

            // --- Mentor Details Form ---
            AppTextField(controller: _mentorTitleController, labelText: 'Mentor Title', hintText: 'e.g., Software Engineer at Google'),
            const SizedBox(height: 16),
            AppTextField(controller: _mentorBioController, labelText: 'Mentor Bio', hintText: 'Describe your experience and what you can help with...', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _mentorExpertiseController, labelText: 'Areas of Expertise', hintText: 'e.g., Flutter, Career Advice, UI/UX'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text('Separate skills with a comma.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 32),
            AppButton(text: 'Save Mentor Profile', onPressed: _saveMentorProfile),
          ],
        ),
      ),
    );
  }
}