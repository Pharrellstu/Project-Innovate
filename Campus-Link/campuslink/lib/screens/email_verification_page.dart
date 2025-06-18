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

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.postRegistrationContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification email sent to ${widget.email}. Please check your inbox and click the link to verify.',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _otpController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When app resumes (like from clicking magic link), refresh auth state
      _checkAuthStatus();
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        // Email is now confirmed, the AuthGate StreamBuilder will handle navigation
        if (mounted) {
          setState(() {
            _successMessage = 'Email verified successfully! Redirecting...';
          });
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
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
          _isLoading = false;
          _successMessage = 'Email successfully verified! Redirecting...';
        });

        // AuthGate will handle navigation automatically
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        if (e.message.toLowerCase().contains("token") &&
            (e.message.toLowerCase().contains("expired") ||
                e.message.toLowerCase().contains("invalid"))) {
          print('EmailVerificationPage: Token error: ${e.message}');
        }
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
          _isLoading = false;
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
      // Use magic link for resend
      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
        emailRedirectTo: 'campuslink://email-confirmed',
      );

      setState(() {
        _successMessage =
            'New verification email sent! Please check your inbox and click the link to verify.';
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
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
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
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A verification email has been sent to:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[850],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Click the link in your email to verify, or enter the 6-digit code below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Verification Code (Optional)',
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
                      counterText: "",
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 6,
                  ),
                  const SizedBox(height: 15),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
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
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('VERIFY CODE'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed:
                              _isLoading ? null : _resendVerificationEmail,
                          child: Text(
                            'Resend Verification Email',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
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
