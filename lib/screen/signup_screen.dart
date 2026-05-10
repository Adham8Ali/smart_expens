import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/widget/CustomTextField.dart';
import 'package:smart_expens/widget/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  void _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        controller: _nameController,
                        hintText: 'full name',
                        icon: Icons.person,
                        keypadType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        keypadType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        controller: _passwordController,
                        obscureText: true,
                        hintText: 'Password',
                        icon: Icons.lock,
                        keypadType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        hintText: 'Confirm Password',
                        icon: Icons.lock,
                        keypadType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Create an account',
                          textcolor: Colors.white,
                          buttoncolor: const Color(0xFF115E38),
                          onPressed: _handleSignup,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                              endIndent: 10,
                            ),
                          ),
                          const Text(
                            'OR',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Colors.black,
                              thickness: 1,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Continue with Google',
                          textcolor: const Color(0xFF115E38),
                          buttoncolor: Colors.white,
                          onPressed: () {
                            // TODO: Implement Google signup
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Color(0xFF115E38),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
