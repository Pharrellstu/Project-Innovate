import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  final String title = "LogIn Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Text("Go to Explore Page"),
        ),
      ),
    );
  }
}
