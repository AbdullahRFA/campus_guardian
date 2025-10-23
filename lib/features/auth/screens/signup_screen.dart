import 'package:campus_guardian/services/auth_service.dart';
import 'package:campus_guardian/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() => _isLoading = true);

    final User? user = await _authService.signUpAndGetUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (user != null) {
      // FIXED: Call 'updateUserProfile' and pass the initial user data.
      await DatabaseService(uid: user.uid).updateUserProfile({
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create account.'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Please log in.'), backgroundColor: Colors.green),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text('Create Your Account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            // AppTextField(controller: _nameController, labelText: 'Full Name'),
            // const SizedBox(height: 20),
            AppTextField(controller: _emailController, labelText: 'Email Address'),
            const SizedBox(height: 20),
            AppTextField(controller: _passwordController, labelText: 'Password', isObscure: true),
            const SizedBox(height: 40),
            AppButton(
              text: 'Create Account',
              onPressed: _isLoading ? null : _handleSignUp,
            ),
            if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Login')),
              ],
            )
          ],
        ),
      ),
    );
  }
}