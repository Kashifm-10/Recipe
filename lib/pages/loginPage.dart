import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:recipe/models/auth_service.dart';
import 'package:recipe/pages/forgotPassword.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/registerPage.dart';
import 'package:recipe/pages/smallScreens/s_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleSignInInProgress = false;
  bool _isEmailSignInInProgress = false;

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isEmailSignInInProgress = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('email, password, name, access, date')
          .eq('email', _emailController.text.toLowerCase().trim())
          .eq('password', _passwordController.text.trim());

      final data = List<Map<String, dynamic>>.from(response);

      if (data.isNotEmpty) {
        String email = data.first['email'];
        String username = data.first['name'];
        String access = data.first['access'];
        String date = data.first['date'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('name', username);
        await prefs.setString('access', access);
        await prefs.setString('date', date);
        await prefs.setBool("isLoggedIn", true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MediaQuery.of(context).size.width > 600
                  ? const MyHomePage()
                  : const MySmallHomePage()),
        );
      } else {
        const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'OOPS!',
            message: 'Invalid Email or Password',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.failure,
            inMaterialBanner: true,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      print("Email sign-in error: $e");
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Colors.red,
          title: 'Login failed!',
          message: 'No Internet Connection',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
    setState(() {
      _isEmailSignInInProgress = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleSignInInProgress = true;
    });

    try {
      await AuthService().signInWithGoogle(context);
    } catch (e) {
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Colors.red,
          title: 'OOPS!',
          message: 'Something went wrong',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
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
                padding: EdgeInsets.only(
                    top: screenWidth > 600
                        ? screenHeight * 0.09
                        : screenWidth * 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Image.asset(
                      'assets/images/banner.png',
                      width: screenWidth > 600
                          ? screenWidth * 0.3
                          : screenWidth * 0.4,
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    /* Text(
                      'Ready to Cook',
                      style: GoogleFonts.hammersmithOne(
                        fontSize: screenWidth > 600
                            ? screenWidth * 0.05
                            : screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C2C2C),
                      ),
                    ), */
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
                        style: GoogleFonts.hammersmithOne(
                          fontSize: 6.w, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5C2C2C),
                        ),
                      ),
                      SizedBox(height: 3.h), // Responsive height
                      SizedBox(
                        height: 5.h, // Responsive text field height
                        child: _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: ' ',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                        ),
                      ),
                      SizedBox(height: 2.h), // Responsive spacing
                      SizedBox(
                        height: 5.h, // Responsive text field height
                        child: _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: ' ',
                          obscureText: true,
                          icon: Icons.lock,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signInWithEmailPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isEmailSignInInProgress // Add the condition for loading state
                                  ? LoadingAnimationWidget.inkDrop(
                                      size: screenWidth * 0.04,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Login',
                                      style: GoogleFonts.hammersmithOne(
                                        fontSize: screenWidth > 600
                                            ? screenWidth * 0.02
                                            : screenWidth * 0.025,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                        ),
                      ),
                      Text(
                        'or',
                        style: GoogleFonts.hammersmithOne(
                            color: const Color(0xFFF59E9E),
                            fontSize: screenWidth > 600
                                ? screenWidth * 0.02
                                : screenWidth * 0.025),
                      ),
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
                          style: GoogleFonts.hammersmithOne(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: screenWidth > 600
                                  ? screenWidth * 0.02
                                  : screenWidth * 0.025),
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
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.hammersmithOne(
                            color: const Color(0xFFF59E9E),
                            fontSize: screenWidth * 0.025,
                            //fontWeight: FontWeight.bold,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign up",
                    style: GoogleFonts.hammersmithOne(
                      color: Colors.white,
                      fontSize: screenWidth > 600
                          ? screenWidth * 0.02
                          : screenWidth * 0.03,
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
  }) {
    final ValueNotifier<bool> isObscured = ValueNotifier(obscureText);

    return ValueListenableBuilder<bool>(
      valueListenable: isObscured,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          obscureText: value,
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
            suffixIcon: label.toLowerCase() == 'password'
                ? IconButton(
                    icon: Icon(
                      value ? HeroiconsMicro.eyeSlash : HeroiconsMicro.eye,
                      color: const Color(0xFF5C2C2C),
                      size: 4.w, // Responsive icon size
                    ),
                    onPressed: () {
                      isObscured.value = !value;
                    },
                  )
                : null,
            labelStyle: GoogleFonts.hammersmithOne(
              fontSize: 3.w, // Responsive font size
              color: const Color(0xFF5C2C2C),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        );
      },
    );
  }
}
