import 'package:flutter/material.dart';
import 'package:smart_expens/screens/login_screen.dart';
import 'package:smart_expens/screens/signup_screen.dart' ;

class MajorScreen extends StatelessWidget {
  const MajorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/Logo.png', width: 150, height: 150),
              const Text(
                'Smart Spend',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF115E38),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Start Tracking Smarter.\nTake control of your money with AI-\npowered insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Color(0xFF115E38),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xff115E38), // لون الحافة
                          width: 2, // سُمك الحافة
                        ),
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Default border radius
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Example navigation to another screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color(0xff115E38), // لون الحافة
                          width: 2, // سُمك الحافة
                        ),
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Default border radius
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Example navigation to another screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff115E38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
