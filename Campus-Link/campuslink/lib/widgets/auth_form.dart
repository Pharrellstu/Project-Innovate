import 'package:flutter/material.dart';
import 'package:campuslink/screens/home_page.dart';

class AuthForm extends StatelessWidget {
  const AuthForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
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
                  // Navigate to Home Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
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
    );
  }
}
