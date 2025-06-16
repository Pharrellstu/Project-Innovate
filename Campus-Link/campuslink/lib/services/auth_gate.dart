import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';
import 'package:campuslink/screens/email_verification_page.dart'; // Import EmailVerificationPage
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/user_service.dart';

// import 'package:campuslink/screens/edit_profile_page.dart'; //TODO: Uncomment when EditProfilePage is implemented
final userService = UserService();

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final authState = snapshot.data;
        final session =
            authState?.session ?? Supabase.instance.client.auth.currentSession;
        final user = session?.user;

        if (user == null) {
          return LoginPage();
        }

        // Check if email is confirmed
        // Supabase sets user.emailConfirmedAt to a timestamp string when confirmed.
        // It's null if not confirmed.
        if (user.emailConfirmedAt == null) {
          // If email is not confirmed, navigate to EmailVerificationPage.
          // Pass the email so the page can use it for resend/display.
          // postRegistrationContext will default to false, which is correct here.
          return EmailVerificationPage(email: user.email!);
        }

        // Email is confirmed, proceed with new user check or HomePage
        final isNewUser = user.userMetadata?['isNewUser'] ?? false;
        if (isNewUser) {
          // TODO: If the user is new, redirect to the edit profile page
          // return EditProfilePage(); // Assuming EditProfilePage might need the user
          // For now, falling through to HomePage if EditProfilePage is commented out.
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
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'isNewUser': true}, // Custom metadata
      );

      // If signUp is successful, response.user should not be null.
      // AuthException would be thrown for issues like user already exists.
      if (response.user == null) {
        print(
          'AuthGate.register: Supabase signUp call returned a null user without an AuthException.',
        );
        // This is an unexpected state, treat as a generic failure.
        throw Exception(
          'Registration failed: No user data returned from Supabase.',
        );
      }

      // User created in auth.users. Now add to our custom 'account' table.
      // This call might throw its own exceptions if it fails (e.g., network, database policy).
      await userService.insertUser(response.user!.id, email);

      // DO NOT call login(email, password) here.
      // The onAuthStateChange stream in AuthGate will detect the new user.
      // AuthForm._handleRegistration will navigate to EmailVerificationPage upon true from this method.
      return true; // Registration process (auth user + custom table entry) successful.
    } on AuthException catch (e) {
      // Specific Supabase authentication error during signUp
      // e.g., "User already registered", "Password should be at least 6 characters", etc.
      print(
        'AuthGate.register: AuthException during Supabase signUp: ${e.message}',
      );
      rethrow; // Rethrow for AuthForm to handle and display
    } catch (e) {
      // Other errors (e.g., from userService.insertUser, network issues not caught as AuthException)
      print(
        'AuthGate.register: Generic error during registration: ${e.toString()}',
      );
      rethrow; // Rethrow for AuthForm to handle and display
    }
  }

  // Method to Login the user
  Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      // If successful, Supabase updates auth state.
      // onAuthStateChange in the AuthGate widget will handle redirection
      // based on email confirmation status (to HomePage or EmailVerificationPage if unconfirmed).
    } on AuthException catch (e) {
      // Log the exception and rethrow it so the caller (AuthForm) can handle it.
      print('Login AuthException from AuthGate.login: ${e.message}');
      rethrow;
    }
    // Other non-AuthException errors (e.g. network) will also propagate.
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
