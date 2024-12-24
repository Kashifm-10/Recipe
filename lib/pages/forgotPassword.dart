import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/mailer.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mailer/smtp_server.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

// Make sure AuthService is available

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // FormKey to manage form validation
  bool _isGoogleSignInInProgress = false;

  bool _isSending = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  final String host = 'smtp.gmail.com'; // Example: smtp.gmail.com
  final int port = 465; // Port for TLS
  final String username = 'noreplyoraction@gmail.com';
//final String password = 'dhur bvcc xvhu fqgg';
  final String password = 'pyaf nqep hcif qnqk';

  // Your custom HTML template

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

    final response = await Supabase.instance.client
        .from('users')
        .select('email')
        .eq('email', _emailController.text.toLowerCase());

    final data = List<Map<String, dynamic>>.from(response);

    if (data.isEmpty) {
      try {
        await Supabase.instance.client.from('users').insert([
          {
            'name': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }
        ]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is registered successfully')),
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text);
        await prefs.setString('user_name', _usernameController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is already registered')),
      );
    }
  }

  String getEmailTemplate(String otp) {
    return '''
   <table width="100%" bgcolor="#fff5e6" cellpadding="0" cellspacing="0" style="margin: 0; padding: 0; font-family: Arial, sans-serif;">
  <tr>
    <td align="center" style="padding: 10px;">
      <!-- Container -->
      <table width="500" cellpadding="0" cellspacing="0" bgcolor="#ffffff" style="border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.15);">
        <tr>
          <td align="center" style="padding: 20px;">
            <!-- Logo -->
            <img src="https://cdn-icons-png.flaticon.com/128/1830/1830839.png" alt="Logo" width="60" style="display: block; margin: 0 auto;">

            <!-- Title -->
            <h1 style="color: #ff6f00; font-size: 24px; margin: 10px 0;">Cook Book</h1>

            <!-- Separator -->
            <img src="https://cdn-icons-png.flaticon.com/128/17632/17632141.png" alt="Icon" width="30" style="margin: 10px auto;">

            <!-- Message -->
            <p style="color: #333; font-size: 14px; line-height: 1.5; margin: 10px 0;">
              Your new password for accessing delicious recipes is:
            </p>

            <!-- OTP -->
            <p style="color: #ff6f00; font-size: 20px; font-weight: bold; margin: 20px 0;">
              $otp
            </p>

            <!-- Footer -->
            <p style="color: #777; font-size: 10px; margin: 0;">
              Thank you for choosing <strong>Cook Book</strong>. Bon Appétit!
            </p>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

    ''';
  }

  String generateRandomPassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = '@#%^&*!()_+[]{}|;:,.<>?';

    // Combine all characters into one pool (without special characters initially)
    final String allCharacters = upperCase + lowerCase + numbers;

    // Create a random generator
    final Random random = Random();

    // Ensure the password has at least one of each character type
    String password = '';
    password += upperCase[random.nextInt(upperCase.length)];
    password += lowerCase[random.nextInt(lowerCase.length)];
    password += numbers[random.nextInt(numbers.length)];
    password += specialChars[random
        .nextInt(specialChars.length)]; // Add exactly one special character

    // Fill the rest of the password (length 8 in total)
    for (int i = 4; i < 8; i++) {
      password += allCharacters[random.nextInt(allCharacters.length)];
    }

    // Shuffle the password to randomize character order
    List<String> passwordChars = password.split('');
    passwordChars.shuffle(random);

    return passwordChars.join();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signInWithEmailPassword() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('email, password, name')
          .eq('email', _emailController.text.toLowerCase());

      final data = List<Map<String, dynamic>>.from(response);

      if (data.isNotEmpty) {
        _sendForgotMail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid email or not registered before')),
        );
      }
    } catch (e) {
      print("Email sign-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: No Internet Connection')));
    }
  }

  Future<void> _sendForgotMail() async {
    setState(() {
      _isGoogleSignInInProgress = true;
    });

    final recipient = _emailController.text.trim();
    if (recipient.isEmpty) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    setState(() => _isSending = true);

    final smtpServer = SmtpServer(host,
        port: port, username: username, password: password, ssl: true);

    String otp = generateRandomPassword();
    print(
        "generateRandomPassword ${generateRandomPassword()}"); // Replace with your OTP logic
    final htmlContent = getEmailTemplate(otp);

    final message = Message()
      ..from = Address(username, 'Cook Book')
      ..recipients.add(recipient)
      ..subject = 'Your OTP for Cook Book'
      ..html = htmlContent;

    await send(message, smtpServer);
    showMailSentDialog(context);
    //  _showSnackBar('Email sent successfully to $recipient.');
    final response = await Supabase.instance.client
        .from('users')
        .update({'password': otp}) // Update password field with the new value
        .eq('email', _emailController.text.toLowerCase()); // Filter by email

    setState(() => _isSending = false);
  }

  void showMailSentDialog(BuildContext context) {
    Dialogs.materialDialog(
      color: Colors.white,
      msg: 'Use the password sent to your mail to login',
      title: 'Mail Sent',
      lottieBuilder: Lottie.asset(
        'assets/lottie_json/mail_sent.json',
        fit: BoxFit.contain,
      ),
      dialogWidth: kIsWeb ? 0.3 : null,
      context: context,
      actions: [
        IconsButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: 'OK',
          iconData: Icons.done,
          color: Colors.blue,
          textStyle: GoogleFonts.poppins(color: Colors.white),
          iconColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Adjust radius as needed
          ),
        )
      ],
    );
  }

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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          title: Text(
            "",
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 40),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: IconButton(
              icon: const Icon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Navigator.pop(context); // Navigate back when pressed
              },
            ),
          ),
          /* actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 40),
            onPressed: () async {
              // Sign out the user
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", false);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ], */
        ),
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
                      ),
                    ),
                    /*  SizedBox(height: screenHeight * 0.09),
                    Text(
                      'Forgot Password',
                      style: GoogleFonts.poppins(
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
                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Forgot Password',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5C2C2C),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            errorText: _emailError,
                            filled: true,
                            fillColor:
                                Colors.grey[200], // Optional: background color
                            // No border and rounded corners
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Rounded corners
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Rounded corners
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior
                                .never, // Prevent label from floating
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton.icon(
                          onPressed: _signInWithEmailPassword,
                          icon: _isSending
                              ? LoadingAnimationWidget.inkDrop(
                                  size: screenWidth * 0.04,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.mail,
                                  color: Colors.white,
                                ),
                          label: Text(
                            'Send Email',
                            style: GoogleFonts.poppins(
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Back to Login",
                    style: GoogleFonts.poppins(
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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            filled: true,
            fillColor: Color(0xFFFEE1D5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Color(0xFF5C2C2C)),
            labelStyle: GoogleFonts.poppins(
              color: Color(0xFF5C2C2C),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
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
    IconData? icon,
    required String? errorText,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            filled: true,
            fillColor: Color(0xFFFEE1D5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Color(0xFF5C2C2C)),
            labelStyle: GoogleFonts.poppins(
              color: Color(0xFF5C2C2C),
            ),
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
      ],
    );
  }

  Widget _buildPasswordTextField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            filled: true,
            fillColor: Color(0xFFFEE1D5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.lock, color: Color(0xFF5C2C2C)),
            labelStyle: GoogleFonts.poppins(
              color: Color(0xFF5C2C2C),
            ),
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
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
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
      ],
    );
  }
}
