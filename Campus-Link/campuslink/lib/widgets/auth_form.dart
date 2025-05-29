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
    });
  }

  void handleSubmit() {
    // TODO: Implement backend validation later!!!

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (isRegistering && password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (isRegistering) {
      // Sign up logic here
      print('Signing up with $email / $password');
    } else {
      // Login logic here
      print('Logging in with $email / $password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Email input
          InputField(
            textEditingController: emailController,
            hintText: 'Email',
            validator: (value) =>
                value!.isEmpty ? 'Please enter your email' : null,
          ),

          // Password input
          InputField(
            textEditingController: passwordController,
            hintText: 'Password',
            validator: (value) =>
                value!.isEmpty ? 'Please enter your password' : null,
          ),

          // buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 20,
            children: [
              // Sign Up button
              TextButton(
                onPressed: () {
                  // your sign up logic here
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.zero, // optional: removes extra spacing
                ),
                child: Text(
                  'Sign up',
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
                  // Navigate to Home Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text(
                  'Log in',
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
    this.validator,
  });

  final TextEditingController textEditingController;
  final String hintText;
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
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        validator: validator ?? validator,
        ),
      );
  }
}
