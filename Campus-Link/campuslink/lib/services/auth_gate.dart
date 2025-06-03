import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    logout();

    if (checkIfLoggedIn()) {
      return HomePage(); // Main app screen
    } else {
      return LoginPage(); // Login/register first
    }
  }

  // Method send SignUp request to the backend
  Future<bool> register(String email, String password) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;

    if (userId == null) {
      return false; // Registration failed
    }
    // If the user is created successfully, insert into aditional values in the 'account' table
    await supabase.from('account').insert({
      'auth_user_id': userId,
      'username': email.split('@')[0], // TEMP: Use email prefix as username
      'email': email,
      'isadmin': false, // ENSURE this is portected on backend
      'isverified': false,
      // Add other fields as needed
    });

    login(email, password); // Automatically log in after registration

    return true; // Registration successful
  }

  // Method to Login the user
  Future<bool> login(String email, String password) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response.user != null;
  }

  // Methood to Logout the user
  Future<void> logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
  }

  bool checkIfLoggedIn() {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }
}
