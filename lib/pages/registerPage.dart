import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:recipe/models/auth_service.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Make sure AuthService is available

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // FormKey to manage form validation
  bool _isGoogleSignInInProgress = false;
  bool _isEmailSignUpInProgress = false;
  bool _obscureText = true;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Add listeners to check if all fields are filled
    _usernameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    super.dispose();
  }

  // Method to update button state based on field inputs
  void _updateButtonState() {
    setState(() {});
  }

  // Method to handle form validation before submission
  bool _validateFields() {
    setState(() {
      _usernameError =
          _usernameController.text.isEmpty ? 'This field is required' : null;
      _emailError =
          _emailController.text.isEmpty ? 'This field is required' : null;
      _passwordError =
          _passwordController.text.isEmpty ? 'This field is required' : null;
    });
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _registerWithEmailPassword() async {
    if (!_validateFields()) {
      return; // If validation fails, do nothing
    }
    setState(() {
      _isEmailSignUpInProgress = true;
    });

    final response = await Supabase.instance.client
        .from('users')
        .select('email')
        .eq('email', _emailController.text.toLowerCase());

    final data = List<Map<String, dynamic>>.from(response);

    if (data.isEmpty) {
      try {
        await Supabase.instance.client.from('users').insert([
          {
            'name': _usernameController.text.toLowerCase(),
            'email': _emailController.text.toLowerCase(),
            'date':
                (DateFormat('dd-MM-yyyy').format(DateTime.now())).toString(),
            'access': false,
            'password': _passwordController.text,
          }
        ]);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text);
        await prefs.setString('name', _usernameController.text);

        setState(() {
          _passwordController.clear();
          _usernameController.clear();
          _emailController.clear();
        });
        const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            color: Colors.green,
            title: 'Registered!',
            message: 'You have successfully registered',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.success,
            inMaterialBanner: true,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        Navigator.pushReplacement(
          context,
          PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.leftToRightWithFade,
            duration: const Duration(milliseconds: 800), // Adjust duration
            child: LoginScreen(),
          ),
        );
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
      }
    } else {
      const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'OOPS!',
            message: 'Email is already registered',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.warning,
            inMaterialBanner: true,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
    }
    setState(() {
      _isEmailSignUpInProgress = false;
    });
  }

  /* Future<void> _signInWithGoogle() async {
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
 */
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if all fields are filled
    bool isFormFilled = _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                        ? screenWidth * 0.15
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
                    /*  SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Create an Account',
                      style: GoogleFonts.hammersmithOne(
                        fontSize: screenWidth > 600
                            ? screenWidth * 0.05
                            : screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C2C2C),
                      ),
                    ), */
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
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
                        Text(
                          'Create an Account',
                          style: GoogleFonts.hammersmithOne(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5C2C2C),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Enter your username',
                          icon: Icons.person,
                          errorText: _usernameError,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildEmailTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                          errorText: _emailError,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildPasswordTextField(screenWidth),
                        SizedBox(height: screenHeight * 0.03),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isFormFilled
                                ? _registerWithEmailPassword
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFormFilled ? Colors.redAccent : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isEmailSignUpInProgress // Add the condition for loading state
                                    ? LoadingAnimationWidget.inkDrop(
                                        size: screenWidth * 0.04,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Register',
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
                        /* Text(
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
                            'Sign up with Google',
                            style: GoogleFonts.hammersmithOne(
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
                        ), */
                      ],
                    ),
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
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Already have an account? Login",
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
    required String? errorText,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              // hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFFEE1D5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              // prefixIcon: Icon(icon, color: Color(0xFF5C2C2C)),
              labelStyle: GoogleFonts.hammersmithOne(
                fontSize: screenWidth * 0.03,
                color: const Color(0xFF5C2C2C),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    required String? errorText,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              //  hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFFEE1D5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              // prefixIcon: Icon(icon, color: Color(0xFF5C2C2C)),
              labelStyle: GoogleFonts.hammersmithOne(
                fontSize: screenWidth * 0.03,
                color: const Color(0xFF5C2C2C),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }

              // Email validation using regex pattern
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null; // Valid email
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? HeroiconsMicro.eyeSlash : HeroiconsMicro.eye,
                  color: const Color(0xFF5C2C2C),
                  size: screenWidth * 0.04,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              labelText: 'Password',
              filled: true,
              fillColor: const Color(0xFFFEE1D5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelStyle: GoogleFonts.hammersmithOne(
                fontSize: screenWidth * 0.03,
                color: const Color(0xFF5C2C2C),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }

              // At least 8 characters
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }

              // Check for at least one uppercase letter, one lowercase letter, one number, and one symbol
              final regex = RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&*(),.?":{}|<>]).{8,}$');
              if (!regex.hasMatch(value)) {
                return 'Password requires uppercase, lowercase, number, and symbol';
              }

              // Check if the password is a simple word (basic example: simple dictionary check)
              List<String> commonPasswords = [
                'password',
                '123456',
                'qwerty',
                'abc123',
                'letmein'
              ];
              if (commonPasswords
                  .any((word) => value.toLowerCase().contains(word))) {
                return 'Password is too common, try something more complex';
              }

              return null; // Valid password
            },
          ),
        ),
      ],
    );
  }
}
