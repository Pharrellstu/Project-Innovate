import 'package:flutter/material.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:campuslink/screens/email_verification_page.dart'; // Ensure this is imported
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for AuthException

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
      _handleRegistration(email, password, confirmPassword);
    } else {
      _handleLogin(email, password);
    }
  }

  void _handleRegistration(
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Make the method async
    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }
    if (!email.endsWith("@student.nhlstenden.com")) {
      _showSnackBar("Only nhlstenden students email addresses are allowed");
      return;
    }

    final authService = AuthGate();
    try {
      bool success = await authService.register(email, password);
      if (mounted) {
        // Check if widget is still in the tree
        if (success) {
          // Navigate to EmailVerificationPage upon successful registration initiation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmailVerificationPage(
                    email: email, // Pass the email used for registration
                    postRegistrationContext:
                        true, // Indicate this is for immediate post-registration
                  ),
            ),
          );
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
        } else {
          // This case should ideally not be reached if AuthGate.register throws on failure
          _showSnackBar('Registration failed. Please try again.');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showSnackBar('Registration failed: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'An unexpected registration error occurred: ${e.toString()}',
        );
      }
    }
  }

  void _handleLogin(String email, String password) async {
    final authService = AuthGate();
    try {
      await authService.login(email, password);
      // If login is successful and email is confirmed, AuthGate's StreamBuilder
      // will handle navigation to HomePage.
      // If login is successful but email is NOT confirmed, AuthGate's StreamBuilder
      // will navigate to EmailVerificationPage.
      // So, we don't need to explicitly navigate to HomePage here.
      // We might show a success message if desired, but AuthGate handles primary navigation.
      if (mounted) {
        // _showSnackBar('Login successful! Redirecting...'); // Optional: if you want a message before AuthGate redirects
      }
    } on AuthException catch (e) {
      if (mounted) {
        if (e.message.toLowerCase().contains("email not confirmed")) {
          // Navigate to EmailVerificationPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmailVerificationPage(
                    email: email, // Pass the email
                    // postRegistrationContext will be false by default
                  ),
            ),
          );
        } else if (e.message.toLowerCase().contains(
          "invalid login credentials",
        )) {
          _showSnackBar('Login failed: Invalid email or password.');
        } else {
          _showSnackBar('Login failed: ${e.message}');
        }
      }
    } catch (e) {
      // Catch any other non-AuthException errors
      if (mounted) {
        _showSnackBar('Login error: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
