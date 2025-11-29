import 'package:campus_guardian/services/auth_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New passwords do not match.')));
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.changePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('To secure your account, please verify your current password before setting a new one.'),
          const SizedBox(height: 24),
          AppTextField(controller: _currentPassController, labelText: 'Current Password', isObscure: true),
          const SizedBox(height: 16),
          AppTextField(controller: _newPassController, labelText: 'New Password', isObscure: true),
          const SizedBox(height: 16),
          AppTextField(controller: _confirmPassController, labelText: 'Confirm New Password', isObscure: true),
          const SizedBox(height: 32),
          AppButton(
            text: _isLoading ? 'Updating...' : 'Update Password',
            onPressed: _isLoading ? null : _handleChangePassword,
          ),
        ],
      ),
    );
  }
}