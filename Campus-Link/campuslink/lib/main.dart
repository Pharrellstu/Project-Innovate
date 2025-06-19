import 'package:flutter/material.dart';
import 'package:campuslink/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandling();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkHandling() {
    _appLinks = AppLinks();

    // Listen for incoming deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('MyApp: Received deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('MyApp: Deep link error: $err');
      },
    );

    // Check for initial link when app starts
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('MyApp: Initial link found: $uri');
        // Delay to ensure the app is fully initialized
        await Future.delayed(const Duration(milliseconds: 500));
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('MyApp: Error checking initial link: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print('MyApp: Processing deep link: $uri');

    if (uri.scheme == 'campuslink' && uri.host == 'email-confirmed') {
      try {
        // Let Supabase handle the authentication
        if (uri.queryParameters.containsKey('code')) {
          print('MyApp: Found confirmation code, processing...');

          // Allow Supabase to process the link
          await Future.delayed(const Duration(milliseconds: 1000));

          // Force navigation back to AuthGate root
          if (_navigatorKey.currentState != null) {
            print('MyApp: Navigating to AuthGate root');
            _navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        print('MyApp: Error handling deep link: $e');
        // Still try to navigate to AuthGate on error
        if (_navigatorKey.currentState != null) {
          _navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: "Campus Link",
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0074CF),
        ).copyWith(primary: const Color(0xFF0074CF)),
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
