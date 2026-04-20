import 'package:flutter/material.dart';
import 'package:smart_expens/widget/CustomTextField.dart';
import 'package:smart_expens/widget/custom_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome back to Smart Spend!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomTextfield(
                hintText: 'full name',
                icon: Icons.person,
                keypadType: TextInputType.name,
              ),
              SizedBox(height: 20),
              CustomTextfield(
                hintText: 'Email',
                icon: Icons.email,
                keypadType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              CustomTextfield(
                obscureText: true,
                hintText: 'Password',
                icon: Icons.lock,
                keypadType: TextInputType.visiblePassword,
              ),
              SizedBox(height: 20),
              CustomTextfield(
                obscureText: true,
                hintText: 'Confirm Password',
                icon: Icons.lock,
                keypadType: TextInputType.visiblePassword,
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Create an account',
                  textcolor: Colors.white,
                  buttoncolor: Color(0xFF115E38),
                  onPressed: () {
                    // Handle login logic here
                  },
                ),
              ),
              SizedBox(height: 20),
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
                  textcolor: Color(0xFF115E38),
                  buttoncolor: Colors.white,
                  onPressed: () {
                    // Handle login logic here
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
