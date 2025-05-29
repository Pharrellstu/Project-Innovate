import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isRegistering = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void toggleForm() {
    setState(() {
      isRegistering = !isRegistering;
      passwordController.clear();
      confirmPasswordController.clear();
    });
  }

  void handleSubmit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (isRegistering) {
      // Sign up logic here
      print('Signing up with $email / $password');
    } else {
      // Login logic here
      print('Logging in with $email / $password');
    }

    // FOR DEMO PURPOSES ONLY
    // Navigate to HomePage after submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ), // Replace with your home page
    );
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email input
          InputField(
            textEditingController: emailController,
            hintText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null; // No error
            },
          ),

          // Password input
          InputField(
            textEditingController: passwordController,
            hintText: 'Password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null; // No error
            },
          ),

          if (isRegistering) ...[
            // Confirm Password input (only for registration)
            InputField(
              textEditingController: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null; // No error
              },
            ),
          ],

          // buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 20,
            children: [
              // Sign Up button
              TextButton(
                onPressed: () {
                  toggleForm();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero, // optional: removes extra spacing
                ),
                child: Text(
                  isRegistering ? 'Log In' : 'Sign Up',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).primaryColor, // button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    handleSubmit();
                  }
                },
                child: Text(
                  isRegistering ? 'Sign Up' : 'Log In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController textEditingController;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
