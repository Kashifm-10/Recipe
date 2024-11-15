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
        .select('email, password, name')
        .eq('email', _emailController.text.toLowerCase())
        .eq('password', _passwordController.text);

    final data = List<Map<String, dynamic>>.from(response);

    if (data.isNotEmpty) {
      print('Success: User authenticated');
      String email = data.first['email'];
      String username = data.first['name'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('name', username);
      await prefs.setBool("isLoggedIn", true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      print('Error: Invalid email or password');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved background image section
            ClipPath(
              clipper: CurvedClipper(),
              child: Container(
                height: screenHeight * 0.4, // Responsive height
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Hello again!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Align(
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
                  SizedBox(height: screenHeight * 0.02),
                  ElevatedButton(
                    onPressed: _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      minimumSize: Size(double.infinity, screenHeight * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  const Text('- OR -', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton.icon(
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
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.infinity, screenHeight * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
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
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 130,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
