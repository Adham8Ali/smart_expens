import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/widgets/CustomTextField.dart';
import 'package:smart_expens/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate all inputs
  String? _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void _handleLogin() async {
    // Validate inputs first
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorDialog(validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      print('🔵 Login Screen: Attempting to login');

      await userProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('✅ Login Screen: Login successful');

      if (mounted) {
        // Clear fields on success
        _emailController.clear();
        _passwordController.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      final errorMessage = e.toString();
      print(' Login Screen: Login error: $errorMessage');

      if (mounted) {
        _showErrorDialog(
          errorMessage
              .replaceFirst('Exception: ', '')
              .replaceFirst('_CastError', 'Authentication failed'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.resetPassword(email);

      if (mounted) {
        _showSuccessDialog(
          'Password reset link has been sent to your email.\n\nCheck your inbox (and spam folder) and follow the link to reset your password.',
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      print('Login Screen: Password reset error: $errorMessage');

      if (mounted) {
        _showErrorDialog(errorMessage.replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Error'),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Success'),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back to Smart Spend!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Login',
                          textcolor: Colors.white,
                          buttoncolor: const Color(0xFF115E38),
                          onPressed: _handleLogin,
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
                            _showErrorDialog(
                              'Google Sign-In coming soon!\n\nFor now, please use email/password authentication.',
                            );
                            // TODO: Implement Google Sign-In
                            // See: https://pub.dev/packages/google_sign_in
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: "Sign up here",
                                  style: const TextStyle(
                                    color: Color(0xFF115E38),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
