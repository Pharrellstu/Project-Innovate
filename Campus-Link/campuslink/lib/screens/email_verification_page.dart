import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final bool postRegistrationContext;
  const EmailVerificationPage({
    super.key,
    required this.email,
    this.postRegistrationContext = false,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.postRegistrationContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification email sent to ${widget.email}. Please check your inbox.',
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP.';
        _isLoading = false;
      });
      return;
    }
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'OTP must be 6 digits.';
        _isLoading = false;
      });
      return;
    }

    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        email: widget.email,
        token: otp,
      );

      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading indicator
          _successMessage = 'Email successfully verified! Redirecting...';
        });

        // After successful verification, this page has done its job.
        // Pop it after a short delay so the user can see the success message.
        // AuthGate will then ensure the correct page (e.g., HomePage) is shown.
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        // Log specific token errors for debugging, but show user the Supabase message
        if (e.message.toLowerCase().contains("token") &&
            (e.message.toLowerCase().contains("expired") ||
                e.message.toLowerCase().contains("invalid"))) {
          print(
            'EmailVerificationPage: Caught \'Token expired/invalid\' error. Message: ${e.message}',
          );
        }
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false; // Stop loading indicator on error
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
          _isLoading = false; // Stop loading indicator on error
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await Supabase.instance.client.auth.resend(
        type:
            OtpType.signup, // Match the type used in registration/verification
        email: widget.email,
      );
      setState(() {
        _successMessage =
            'Verification email resent successfully. Please check your inbox.';
        _isLoading = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend email: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: !widget.postRegistrationContext,
        leading:
            !widget.postRegistrationContext
                ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30.0),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                shadows: const [
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
                children: <Widget>[
                  Image.asset("resources/img/logo.jpeg", height: 100),
                  const SizedBox(height: 20),
                  Text(
                    'Verify Your Email',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A verification code has been sent to:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    '${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[850], fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Please enter it below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter 6-digit code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      counterText: "", // Hide the default counter
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 6,
                  ),
                  const SizedBox(height: 25),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          50,
                        ), // Make button wider
                      ),
                      child: const Text('VERIFY'),
                    ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _isLoading ? null : _resendVerificationEmail,
                    child: Text(
                      'Resend Verification Email',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
