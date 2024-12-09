import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe/models/auth_service.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/biggerScreens/registerPage.dart';
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
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('email, password, name')
          .eq('email', _emailController.text.toLowerCase())
          .eq('password', _passwordController.text);

      final data = List<Map<String, dynamic>>.from(response);

      if (data.isNotEmpty) {
        String email = data.first['email'];
        String username = data.first['name'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('name', username);
        await prefs.setBool("isLoggedIn", true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      print("Email sign-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: No Internet Connection')));
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

    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside a text field
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset:
            false, // Disable screen resizing when keyboard appears
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/log_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E9E),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: screenWidth * 0.06,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Ready to Cook',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C2C2C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C2C2C),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.email,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        obscureText: true,
                        icon: Icons.lock,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signInWithEmailPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E9E),
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: screenWidth * 0.02,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () {
                          // Forgot password logic
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: const Color(0xFFF59E9E),
                            fontSize: screenWidth * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: _isGoogleSignInInProgress
                            ? LoadingAnimationWidget.inkDrop(
                                size: screenWidth * 0.04,
                                color: Colors.white,
                              )
                            : SvgPicture.asset(
                                'assets/icons/google_icon.svg', // Make sure to use your correct asset path
                                height: screenWidth *
                                    0.04, // Adjust the size as needed
                                width: 100.0,
                              ),
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.02),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize:
                              Size(double.infinity, screenHeight * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
    required IconData icon,
    required double screenWidth,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFFEE1D5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF5C2C2C)), // Icon color
        labelStyle: const TextStyle(
          color: Color(0xFF5C2C2C), // Set label color same as the icon
        ),
      ),
    );
  }
}
