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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            AppTextField(
              controller: _emailController,
              labelText: 'Email Address',
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _passwordController,
              labelText: 'Password',
              isObscure: true,
            ),
            const SizedBox(height: 40),
            AppButton(
              text: 'Login',
              onPressed: () {
                // We'll add Firebase logic here tomorrow
                print('Email: ${_emailController.text}');
                print('Password: ${_passwordController.text}');
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Sign Up'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}