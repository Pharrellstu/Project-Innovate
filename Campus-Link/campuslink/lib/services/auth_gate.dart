import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';
import 'package:campuslink/screens/email_verification_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/user_service.dart';
import 'dart:async';

final userService = UserService();

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();

  // Static methods that can be called from anywhere in the app
  static String? getCurrentUserId() {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.user.id;
  }

  static Future<bool> register(String email, String password) async {
    final supabase = Supabase.instance.client;
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'isNewUser': true}, // Custom metadata
        emailRedirectTo: 'campuslink://email-confirmed',
      );

      if (response.user == null) {
        print(
          'AuthGate.register: Supabase signUp call returned a null user without an AuthException.',
        );
        throw Exception(
          'Registration failed: No user data returned from Supabase.',
        );
      }

      await userService.insertUser(response.user!.id, email);
      return true;
    } on AuthException catch (e) {
      print(
        'AuthGate.register: AuthException during Supabase signUp: ${e.message}',
      );
      rethrow;
    } catch (e) {
      print(
        'AuthGate.register: Generic error during registration: ${e.toString()}',
      );
      rethrow;
    }
  }

  static Future<void> login(String email, String password) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      print('Login AuthException from AuthGate.login: ${e.message}');
      rethrow;
    }
  }

  static Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  late StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      print(
        'AuthGate: Auth event received: $event. User: ${data.session?.user?.email}, Confirmed: ${data.session?.user?.emailConfirmedAt}',
      );

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        print(
          'AuthGate: Relevant auth event ($event), forcing UI rebuild via setState.',
        );
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('AuthGate: App resumed - checking auth state');
      // Small delay to allow any deep link processing to complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final currentSession = Supabase.instance.client.auth.currentSession;
        final currentUser = Supabase.instance.client.auth.currentUser;

        print('AuthGate StreamBuilder Rebuilding:');
        print(
          '  Snapshot has data: ${snapshot.hasData}, Event: ${snapshot.data?.event}',
        );
        print(
          '  Supabase.currentUser: ${currentUser?.email}, Confirmed: ${currentUser?.emailConfirmedAt}',
        );
        print(
          '  Supabase.currentSession: ${currentSession?.user.email}, Confirmed: ${currentSession?.user.emailConfirmedAt}',
        );

        final User? userToEvaluate = currentUser ?? currentSession?.user;

        if (userToEvaluate == null) {
          print('AuthGate: User is null. Navigating to LoginPage.');
          return LoginPage();
        }

        if (userToEvaluate.emailConfirmedAt == null) {
          print(
            'AuthGate: User email NOT confirmed (${userToEvaluate.emailConfirmedAt}). Navigating to EmailVerificationPage for ${userToEvaluate.email}.',
          );
          return EmailVerificationPage(email: userToEvaluate.email!);
        }

        print(
          'AuthGate: User email IS confirmed. Navigating to HomePage for ${userToEvaluate.email}.',
        );
        final isNewUser = userToEvaluate.userMetadata?['isNewUser'] ?? false;
        if (isNewUser) {
          print('AuthGate: User is new. TODO: Redirect to edit profile page.');
          // TODO: If the user is new, redirect to the edit profile page
        }
        return HomePage();
      },
    );
  }
}
