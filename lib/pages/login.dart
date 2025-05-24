import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/services/auth.dart';
import 'package:menu_planner/pages/sign_up.dart';
import 'package:menu_planner/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_planner/models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String _getFirebaseErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This user has been disabled.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    default:
      return 'An unknown error occurred: ${e.message}';
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _savePassword = false;
  bool _obscurePassword = true;
  String? _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await Auth().signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Fetch user details to verify display name
        final user = await Auth().getCurrentUser();
        if (user?.displayName != _usernameController.text) {
          setState(() {
            _errorMessage = 'Display name does not match.';
          });
          return;
        }

        // This will automatically handle the user data loading
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _errorMessage = e.message ?? 'Authentication failed');
      } catch (e) {
        setState(() => _errorMessage = 'Welcome back! Loading your data...');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _handleAuthError(dynamic error) {
    if (error.toString().contains('PigeonUserDetails')) {
      // This indicates auth succeeded but type conversion failed
      return 'Login successful! Loading your data...';
    }
    return 'An error occurred: ${error.toString()}';
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore, if not create profile
        final userData = await Auth().getUserData(userCredential.user!.uid);
        if (userData.isEmpty) {
          // Create user profile in Firestore
          await Auth().createUserProfile(
            AppUser(
              uid: userCredential.user!.uid,
              email: userCredential.user!.email ?? '',
              displayName: userCredential.user!.displayName,
            ),
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign-in failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02197D),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Access your account securely by using your email and password",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(97, 220, 220, 220),
                      prefixIcon:
                          const Icon(Icons.person, color: Color(0xFF02197D)),
                      labelText: 'User Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(97, 220, 220, 220),
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xFF02197D)),
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(97, 220, 220, 220),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xFF02197D)),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _savePassword,
                            onChanged: (value) {
                              setState(() {
                                _savePassword = value!;
                              });
                            },
                          ),
                          const Text("Save password"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forget password?",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 10, left: 15, right: 15),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Or continue with",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata,
                          size: 24, color: Colors.red),
                      label: const Text("Continue with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(189, 255, 255, 255),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Color(0xFF02197D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
