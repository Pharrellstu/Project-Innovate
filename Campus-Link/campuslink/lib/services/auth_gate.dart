import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';
import 'package:campuslink/screens/login_page.dart';
import 'package:campuslink/screens/email_verification_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuslink/services/user_service.dart';
import 'package:app_links/app_links.dart';
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupDeepLinkHandling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _setupDeepLinkHandling() {
    _appLinks = AppLinks();

    // Listen for auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      print('Auth event: $event');
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        print('User signed in or token refreshed - rebuilding UI');
        if (mounted) {
          setState(() {});
        }
      }
    });

    // Listen for incoming deep links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('Received deep link: $uri');
        _handleIncomingLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );

    // Check for initial link when app starts
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('Initial link found: $uri');
        _handleIncomingLink(uri);
      }
    } catch (e) {
      print('Error checking initial link: $e');
    }
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    print('Processing incoming link: $uri');

    if (uri.scheme == 'campuslink' && uri.host == 'email-confirmed') {
      try {
        // Extract the fragment and query parameters
        final fragment = uri.fragment;
        final queryParams = uri.queryParameters;

        print('Link fragment: $fragment');
        print('Link query params: $queryParams');

        // If there's a fragment, it might contain the auth tokens
        if (fragment.isNotEmpty) {
          // Parse fragment as query string
          final fragmentParams = Uri.splitQueryString(fragment);
          print('Fragment params: $fragmentParams');

          if (fragmentParams.containsKey('access_token')) {
            // This is the auth callback with tokens
            await Supabase.instance.client.auth.getSessionFromUrl(uri);
            print('Session recovered from URL successfully');

            // Force UI rebuild
            if (mounted) {
              setState(() {});
            }
            return;
          }
        }

        // Fallback: try to refresh the session
        await Supabase.instance.client.auth.refreshSession();
        print('Session refreshed as fallback');

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error processing auth link: $e');
        // Force UI rebuild even if session recovery fails
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed - checking auth state');
      // Small delay to ensure any deep link processing is complete
      Future.delayed(const Duration(milliseconds: 500), () {
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
        final authState = snapshot.data;
        final session =
            authState?.session ?? Supabase.instance.client.auth.currentSession;
        final user = session?.user;

        print(
          'AuthGate build - User: ${user?.email}, Email confirmed: ${user?.emailConfirmedAt}',
        );

        if (user == null) {
          return LoginPage();
        }

        // Check if email is confirmed
        if (user.emailConfirmedAt == null) {
          return EmailVerificationPage(email: user.email!);
        }

        // Email is confirmed, proceed with new user check or HomePage
        final isNewUser = user.userMetadata?['isNewUser'] ?? false;
        if (isNewUser) {
          // TODO: If the user is new, redirect to the edit profile page
        }

        return HomePage();
      },
    );
  }
}
