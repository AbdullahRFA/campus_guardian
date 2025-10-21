import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers for all the fields
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController(text: "Jahangirnagar University");
  final _departmentController = TextEditingController();
  final _sessionController = TextEditingController();
  final _batchController = TextEditingController();
  final _classRollController = TextEditingController();
  final _bscCgpaController = TextEditingController();
  final _mscCgpaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _facebookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch existing data to populate fields
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        _fullNameController.text = data['fullName'] ?? '';
        _departmentController.text = data['department'] ?? '';
        _sessionController.text = data['session'] ?? '';
        _batchController.text = data['batch'] ?? '';
        _classRollController.text = data['classRoll'] ?? '';
        _bscCgpaController.text = data['bscCgpa'] ?? '';
        _mscCgpaController.text = data['mscCgpa'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _linkedinController.text = data['linkedinUrl'] ?? '';
        _facebookController.text = data['facebookUrl'] ?? '';
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> updatedData = {
        'fullName': _fullNameController.text.trim(),
        'university': _universityController.text.trim(),
        'department': _departmentController.text.trim(),
        'session': _sessionController.text.trim(),
        'batch': _batchController.text.trim(),
        'classRoll': _classRollController.text.trim(),
        'bscCgpa': _bscCgpaController.text.trim(),
        'mscCgpa': _mscCgpaController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'linkedinUrl': _linkedinController.text.trim(),
        'facebookUrl': _facebookController.text.trim(),
      };

      await DatabaseService(uid: user!.uid).updateUserProfile(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            AppTextField(controller: _fullNameController, labelText: 'Full Name'),
            const SizedBox(height: 16),
            AppTextField(controller: _universityController, labelText: 'University'),
            const SizedBox(height: 16),
            AppTextField(controller: _departmentController, labelText: 'Department'),
            const SizedBox(height: 16),
            AppTextField(controller: _sessionController, labelText: 'Session'),
            const SizedBox(height: 16),
            AppTextField(controller: _batchController, labelText: 'Batch'),
            const SizedBox(height: 16),
            AppTextField(controller: _classRollController, labelText: 'Class Roll'),
            const SizedBox(height: 16),
            AppTextField(controller: _bscCgpaController, labelText: 'B.Sc CGPA'),
            const SizedBox(height: 16),
            AppTextField(controller: _mscCgpaController, labelText: 'M.Sc CGPA'),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: 'Phone Number'),
            const SizedBox(height: 16),
            AppTextField(controller: _bioController, labelText: 'Bio', hintText: 'A short bio about yourself...'),
            const SizedBox(height: 16),
            AppTextField(controller: _linkedinController, labelText: 'LinkedIn Profile URL'),
            const SizedBox(height: 16),
            AppTextField(controller: _facebookController, labelText: 'Facebook Profile URL'),
            const SizedBox(height: 32),
            AppButton(text: 'Save Changes', onPressed: _saveProfile),
          ],
        ),
      ),
    );
  }
}