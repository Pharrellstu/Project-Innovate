import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/db_handler.dart';
// import 'package:campuslink/screens/edit_profile_page.dart'; //TODO: Uncomment when EditProfilePage is implemented

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return LoginPage();
        }

        final isNewUser = session.user.userMetadata?['isNewUser'] ?? false;
        if (isNewUser) {
          // TODO: If the user is new, redirect to the edit profile page
          // return EditProfilePage();
        }

        return HomePage();
      },
    );
  }

  // Get current userID
  static String? getCurrentUserId() {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.user.id;
  }

  // Method send SignUp request to the backend
  Future<bool> register(String email, String password) async {
    final supabase = Supabase.instance.client;
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'isNewUser': true, // Custom metadata
      },
    );

    final userId = response.user?.id;

    if (userId == null) {
      return false; // Registration failed
    }

    // If the user is created successfully, insert into aditional values in the 'account' table
    await DbHandler().insertUser(userId, email);

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
  static Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }
}
