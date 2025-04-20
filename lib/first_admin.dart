import 'package:clay_craft_project/second_admin.dart';
import 'package:clay_craft_project/third_admin.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clay_craft_project/services/auth_service.dart';

class FirstAdmin extends StatefulWidget {
  const FirstAdmin({super.key});

  @override
  State<FirstAdmin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<FirstAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        String emailAddress = _emailController.text.trim();
        String password = _passwordController.text;

        UserCredential userCredential = await _authService.signInWithEmailAndPassword(
          emailAddress, 
          password
        );

        User? user = userCredential.user;

        if (user != null) {
          // Check if email is verified
          if (!_authService.isEmailVerified(user)) {
            // Show dialog with option to resend verification email
            if (!mounted) return;
            await _showVerificationDialog(user.email ?? '');
            await _authService.signOut();
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // Check if user is admin
          bool isAdmin = await _authService.isUserAdmin(user.uid);
          if (!isAdmin) {
            _showSnackBar('This account does not have admin privileges.');
            await _authService.signOut();
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // Navigate to admin dashboard
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ThirdAdmin()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';
        
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This user account has been disabled.';
        }
        
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } else {
      _showSnackBar('Please enter both email and password');
    }
  }

  // Show dialog for email verification
  Future<void> _showVerificationDialog(String email) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool _isSending = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Email Verification Required'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Icon(
                      Icons.mark_email_unread,
                      size: 50,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Your email ($email) is not verified.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please check your inbox and click on the verification link we sent you.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'If you cannot find the email, check your spam folder or request a new verification email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Resend Verification Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            _isSending = true;
                          });
                          try {
                            // First sign in again to get the user
                            UserCredential userCredential = await _authService.signInWithEmailAndPassword(
                              _emailController.text.trim(), 
                              _passwordController.text
                            );
                            
                            if (userCredential.user != null) {
                              await userCredential.user!.sendEmailVerification();
                              Navigator.of(context).pop();
                              _showSnackBar('Verification email sent. Please check your inbox.');
                            }
                          } catch (e) {
                            setState(() {
                              _isSending = false;
                            });
                            Navigator.of(context).pop();
                            _showSnackBar('Error sending verification email: ${e.toString()}');
                          }
                        },
                      ),
              ],
            );
          }
        );
      },
    );
  }

  // Show dialog for password reset
  Future<void> _showPasswordResetDialog() async {
    final TextEditingController _resetEmailController = TextEditingController();
    _resetEmailController.text = _emailController.text.trim();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool _isSending = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Enter your email address and we will send you a link to reset your password.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _resetEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      )
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Send Reset Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final email = _resetEmailController.text.trim();
                          if (email.isEmpty) {
                            _showSnackBar('Please enter your email address');
                            return;
                          }
                          
                          setState(() {
                            _isSending = true;
                          });
                          
                          try {
                            await _authService.resetPassword(email);
                            Navigator.of(context).pop();
                            _showSnackBar('Password reset email sent. Please check your inbox.');
                          } catch (e) {
                            setState(() {
                              _isSending = false;
                            });
                            Navigator.of(context).pop();
                            _showSnackBar('Error sending password reset email: ${e.toString()}');
                          }
                        },
                      ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Google as admin
      await _authService.signInWithGoogle(true);
      
      if (!mounted) return;
      
      // Navigate to admin dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ThirdAdmin()),
      );
    } catch (e) {
      _showSnackBar('Google Sign-In failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Assets.images1,
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 300,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 108, 89, 63),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CLAY CRAFT',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 108, 89, 63),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 108, 89, 63),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _showPasswordResetDialog,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 108, 89, 63),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SecondAdmin()),
                            );
                          },
                          child: const Text(
                            'You do not have an account? Sign up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 108, 89, 63),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 30,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: _signInWithGoogle,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
