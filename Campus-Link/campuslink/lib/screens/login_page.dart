import 'package:flutter/material.dart';
import 'package:campuslink/widgets/auth_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  final String title = "LogIn Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background - fill page
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),

        child: Center(
          // Login form container
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("resources/img/logo.jpeg", width: 180, height: 180),
                AuthForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
