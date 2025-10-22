import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/services/storage_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  XFile? _imageFile;
  String _networkImageUrl = '';
  final _storageService = StorageService();

  // Define all controllers
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

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _fullNameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _sessionController.dispose();
    _batchController.dispose();
    _classRollController.dispose();
    _bscCgpaController.dispose();
    _mscCgpaController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data != null && mounted) {
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
      _networkImageUrl = data['profilePicUrl'] ?? '';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _pickImage() async {
    final file = await _storageService.pickImage();
    if (file != null && mounted) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser!;
    String finalImagePath = _networkImageUrl;

    if (_imageFile != null && !kIsWeb) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = '${user.uid}_profile.jpg';
        final savedImagePath = path.join(directory.path, fileName);
        await File(_imageFile!.path).copy(savedImagePath);
        finalImagePath = savedImagePath;
      } catch (e) {
        // Handle error if image fails to save
      }
    }

    Map<String, dynamic> updatedData = {
      'profilePicUrl': finalImagePath,
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

    try {
      await DatabaseService(uid: user.uid).updateUserProfile(updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path))) as ImageProvider
                        : (_networkImageUrl.isNotEmpty
                        ? (_networkImageUrl.startsWith('http') ? NetworkImage(_networkImageUrl) : FileImage(File(_networkImageUrl))) as ImageProvider
                        : null),
                    child: _imageFile == null && _networkImageUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(icon: const Icon(Icons.camera_alt), onPressed: _pickImage),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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