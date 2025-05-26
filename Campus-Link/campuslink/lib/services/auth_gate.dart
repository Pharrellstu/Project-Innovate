import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (checkIfLoggedIn()) {
      return HomePage(); // Main app screen
    } else {
      return LoginPage(); // Login/register first
    }
  }

  bool checkIfLoggedIn() {
    // TODO: Implement your logic to check if the user is logged in.
    // This could be checking a token, shared preferences, or any other method
    // Example: check from shared prefs, Firebase auth, etc.
    return false;
  }
}
