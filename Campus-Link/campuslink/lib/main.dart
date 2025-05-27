import 'package:flutter/material.dart';
import 'package:campuslink/services/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Campus Link",
      
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0074CF),
        ).copyWith(primary: Color(0xFF0074CF)),
      ),
      
      home: const AuthGate(),

      debugShowCheckedModeBanner: false, // This hides the debug banner
    );
  }
}
