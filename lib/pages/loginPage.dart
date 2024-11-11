import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe/models/auth_service.dart';
import 'package:recipe/pages/home.dart';
import 'package:recipe/pages/registerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleSignInInProgress = false;

  Future<void> _signInWithEmailPassword() async {
    // Query the 'users' table to find the matching email and password
    final response = await Supabase.instance.client
        .from('users')
        .select('email, password, name') // Select email and password fields
        .eq('email', _emailController.text.toLowerCase()) // Match the email
        .eq('password', _passwordController.text);

    // Convert the response to a list of maps
    final data = List<Map<String, dynamic>>.from(response);

    // Check if any data is returned
    if (data.isNotEmpty) {
      // If there's a match, print success
      print('Success: User authenticated');
      // Extract the email from the response
      String email = data.first['email'];
      String username = data.first['name'];

      // Optionally, print or use the email
      print('Authenticated user email: $email');
      print('Authenticated user name: $username');

      // Save the email to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email); // Save the email
      await prefs.setString('name', username); // Save the email
      await prefs.setBool("isLoggedIn", true);

      // Navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      // If no match is found, print error
      print('Error: Invalid email or password');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }

    // Handle errors during query or authentication
    try {
      // Additional error handling can be done here, such as checking network errors
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleSignInInProgress = true;
    });

    try {
      await AuthService().signInWithGoogle(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isGoogleSignInInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Curved background image section
            ClipPath(
              clipper: CurvedClipper(), // Custom clipper for curved effect
              child: Container(
                height: 500,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/login_bg.jpg'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hello again!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Purple color for title
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Forgot password logic
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 200.0),
                  child: ElevatedButton(
                    onPressed: _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple, // Purple button color
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('- OR -', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 200.0),
                  child: ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: _isGoogleSignInInProgress
                        ? LoadingAnimationWidget.inkDrop(
                            size: 24,
                            color: Colors.white,
                          )
                        : const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // Google button color
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    ); // Navigate to sign-up page
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                const SizedBox(height: 30), // Additional spacing at the bottom
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
    );
  }
}

// Custom Clipper for Curved Bottom Edge
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 150); // Start point for the curve
    path.quadraticBezierTo(
      size.width / 2, size.height, // Control point
      size.width, size.height - 150, // End point for the curve
    );
    path.lineTo(size.width, 0); // Top-right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
