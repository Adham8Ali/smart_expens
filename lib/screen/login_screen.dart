import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/widget/CustomTextField.dart';
import 'package:smart_expens/widget/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.login(
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

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Please enter your email address');
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.resetPassword(_emailController.text.trim());
      _showSuccessDialog('Password reset link sent to your email');
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          // TODO: Implement Google login
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Signup",
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
              ),
            ),
    );
  }
}
