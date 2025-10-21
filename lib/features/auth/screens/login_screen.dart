import 'package:campus_guardian/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ... inside _LoginScreenState

  void _handleSignIn() async {
    setState(() => _isLoading = true);

    final error = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // We set isLoading to false after the await call, regardless of the outcome.
    // This must be done before any navigation.
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      // If there was an error, show it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      // SUCCESS! Navigate to the main app dashboard.
      context.go('/app/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Text('Welcome Back!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            AppTextField(controller: _emailController, labelText: 'Email Address'),
            const SizedBox(height: 20),
            AppTextField(controller: _passwordController, labelText: 'Password', isObscure: true),
            const SizedBox(height: 40),
            AppButton(
              text: 'Login',
              onPressed: _isLoading ? null : _handleSignIn,
            ),
            if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(onPressed: () => context.go('/signup'), child: const Text('Sign Up')),
              ],
            )
          ],
        ),
      ),
    );
  }
}