import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';

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
                Form(
                  // key: _formKey,
                  child: Column(
                    children: [
                      // Email input
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          // controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email / Username',
                            border: InputBorder.none,
                          ),
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                        ),
                      ),

                      // Password input
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: InputBorder.none,
                          ),
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                        ),
                      ),

                      // buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 20,
                        children: [
                          // Sign Up button
                          TextButton(
                            onPressed: () {
                              // your sign up logic here
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding:
                                  EdgeInsets
                                      .zero, // optional: removes extra spacing
                            ),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Login button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).primaryColor, // button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // your login logic here
                            },
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
