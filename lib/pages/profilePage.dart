import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_popup/flutter_popup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late GifController _controller;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final _femailController = TextEditingController();
  bool _isGoogleSignInInProgress = false;
  final String host = 'smtp.gmail.com'; // Example: smtp.gmail.com
  final int port = 465; // Port for TLS
  final String username = 'noreplyoraction@gmail.com';
//final String password = 'dhur bvcc xvhu fqgg';
  final String password = 'pyaf nqep hcif qnqk';

  bool _isSending = false;
  String changePassword = '0';

  final firebase_auth.User? user =
      firebase_auth.FirebaseAuth.instance.currentUser;
  String? email = '';
  String? name = '';
  String? date = '';
  Future<void> _getUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      name = prefs.getString('name');
      date = prefs.getString('date') ?? ' ';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);

    _getUserDataFromPrefs();
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word; // Handle empty strings safely
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

/*   Future<void> changePasswordDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      changePassword = '0';
                    });
                  },
                  icon: Icon(FontAwesomeIcons.arrowLeft, size: 18.sp)),
              Text(
                'Change Password',
                style: GoogleFonts.hammersmithOne(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Password Field
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        hintText: 'Enter your current password',
                        labelStyle: GoogleFonts.hammersmithOne(
                            color: Colors.black, fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!, // Default border color
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                Colors.grey[300]!, // Border color when focused
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors
                                .grey[300]!, // Border color when not focused
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50], // Background color
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      style: GoogleFonts.hammersmithOne(
                        fontSize: 14.sp, // Font size adjustment
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Current password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        labelStyle: GoogleFonts.hammersmithOne(
                            color: Colors.black, fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!, // Default border color
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                Colors.grey[300]!, // Border color when focused
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors
                                .grey[300]!, // Border color when not focused
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50], // Background color
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      style: GoogleFonts.hammersmithOne(
                        fontSize: 14.sp, // Font size adjustment
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value == _currentPasswordController.text) {
                          return 'Password cannot be same as old';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        final regex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
                        if (!regex.hasMatch(value)) {
                          return 'Password requires uppercase, lowercase, number, and symbol';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your new password',
                        labelStyle: GoogleFonts.hammersmithOne(
                            color: Colors.black, fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!, // Default border color
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color:
                                Colors.grey[300]!, // Border color when focused
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors
                                .grey[300]!, // Border color when not focused
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50], // Background color
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      style: GoogleFonts.hammersmithOne(
                        fontSize: 14.sp, // Font size adjustment
                      ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showForgotPasswordDialog(context);
                        },
                        child: Text("Forgot password?",
                            style: GoogleFonts.hammersmithOne(
                                color: Colors.blue, fontSize: 13.sp))),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: GoogleFonts.hammersmithOne(fontSize: 16.sp),
              ),
              child: Text('Cancel', style: GoogleFonts.hammersmithOne()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Validate Current Password with Supabase
                  final validateResponse = await Supabase.instance.client
                      .from('users')
                      .select('email, password, name')
                      .eq('email', email!.toLowerCase().trim())
                      .eq('password', _currentPasswordController.text.trim());

                  if (validateResponse.isEmpty) {
                    const snackBar = SnackBar(
                      /// need to set following properties for best effect of awesome_snackbar_content
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        color: Colors.red,
                        title: 'Oh Snap!',
                        message: 'Invalid current password',

                        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                        contentType: ContentType.failure,
                        inMaterialBanner: true,
                      ),
                    );

                    return;
                  }

                  // Update Password in Supabase
                  final updateResponse = await Supabase.instance.client
                      .from('users')
                      .update({
                    'password': _newPasswordController.text.trim()
                  }).eq('email', email!.toLowerCase().trim());

                  Navigator.of(context).pop(); // Close the dialog
                  const snackBar = SnackBar(
                    /// need to set following properties for best effect of awesome_snackbar_content
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      color: Colors.green,
                      title: 'Yay!',
                      message: 'Password changed successfully!',

                      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                      contentType: ContentType.success,
                      inMaterialBanner: true,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 241, 175, 206),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: GoogleFonts.hammersmithOne(fontSize: 16.sp),
              ),
              child: Text('Confirm', style: GoogleFonts.hammersmithOne()),
            ),
          ],
        );
      },
    );
  }
 */
/*   Future<void> _showForgotPasswordDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _femailController.clear();

    final _formKey =
        GlobalKey<FormState>(); // FormKey to manage form validation
    String? _emailError =
        _femailController.text.isEmpty ? 'This field is required' : null;

    showDialog(
      context: context,
      barrierDismissible:
          true, // Prevents dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Forgot Password',
                  style: GoogleFonts.hammersmithOne(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C2C2C),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextFormField(
                  controller: _femailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                    labelStyle: GoogleFonts.hammersmithOne(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!, // Default border color
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!, // Border color when focused
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color:
                            Colors.grey[300]!, // Border color when not focused
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50], // Background color
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  style: GoogleFonts.hammersmithOne(
                    fontSize: 14.sp, // Font size adjustment
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // Check if email is empty
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    // Check if the email matches a specific email (replace 'email' with the desired email)
                    if (value != email) {
                      return 'Email does not match';
                    }
                    // Check if the email format is correct
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isGoogleSignInInProgress =
                          true; // Set to true when the button is pressed
                    });

                    // Trigger form validation before calling `validateIfExists()`
                    if (_formKey.currentState?.validate() ?? false) {
                      vadlidateIfExists(); // Call your function here
                    } else {
                      setState(() {
                        _isGoogleSignInInProgress =
                            false; // Reset to false when validation fails
                      });
                    }
                  },
                  icon: _isGoogleSignInInProgress
                      ? LoadingAnimationWidget.inkDrop(
                          size: screenWidth * 0.04,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.mail,
                          color: Colors.white,
                        ),
                  label: Text(
                    'Send Email',
                    style: GoogleFonts.hammersmithOne(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: screenWidth > 600
                          ? screenWidth * 0.02
                          : screenWidth * 0.025,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, screenHeight * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
 */
  Future<void> vadlidateIfExists() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('email, password, name')
          .eq('email', email!.toLowerCase().trim());

      final data = List<Map<String, dynamic>>.from(response);

      if (data.isNotEmpty) {
        _sendForgotMail();
      } else {
        setState(() {
          _isGoogleSignInInProgress = false;
        });
        const snackBar = SnackBar(
          /// need to set following properties for best effect of awesome_snackbar_content
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'OOPS!',
            message: 'Invalid Email or Not Registered',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.warning,
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
  }

  Future<void> _sendForgotMail() async {
    /*  setState(() {
      _isGoogleSignInInProgress = true;
    }); */

    final recipient = email!.trim();
    if (recipient.isEmpty) {
      const snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Colors.red,
          title: 'Invalid!',
          message: 'Please enter a valid email address',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
          inMaterialBanner: true,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
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
    /*  const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        color: Colors.green,
        title: 'Mail Sent!',
        message: 'Password reset successfully!',
        contentType: ContentType.success,
        inMaterialBanner: true,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar); */
    var materialBanner = MaterialBanner(
      /// Setting properties for best effect of awesome_snackbar_content
      elevation: 5, // Optional, depending on your design preference
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        color: Colors
            .blue[300], // This color matches the original SnackBar's background
        title: 'Mail Sent',
        message: 'Password reset successfull!',
        contentType:
            ContentType.warning, // Keep it as warning (same as the SnackBar)
        inMaterialBanner: true,
      ),
      actions: const [
        SizedBox.shrink()
      ], // Add actions or modify based on requirements
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner() // Hide any existing MaterialBanner
      ..showMaterialBanner(materialBanner); // Show the new MaterialBanner

// Auto-hide the materialBanner after a certain duration
    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context)
          .hideCurrentMaterialBanner(); // Hide the banner after 3 seconds
    });
    final response = await Supabase.instance.client
        .from('users')
        .update({'password': otp}) // Update password field with the new value
        .eq('email', email!.toLowerCase()); // Filter by email

    setState(() {
      _isGoogleSignInInProgress = false;
      _isSending = false;
    });
  }

  String generateRandomPassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = '@#%&*!?'; //'@#%^&*!()_+[]{}|;:,.<>?';

    // Combine all characters into one pool (without special characters initially)
    const String allCharacters = upperCase + lowerCase + numbers;

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
            <img src="https://res.cloudinary.com/dcrm8qosr/image/upload/v1740335403/logo.png" alt="Logo" width="60" style="display: block; margin: 0 auto;">

           <!-- Message -->
            <p style="color: #333; font-size: 14px; line-height: 1.5; margin: 10px 0;">
              Your new password for accessing delicious recipes is:
            </p>

            <!-- Separator -->
            <img src="https://cdn-icons-png.flaticon.com/128/17632/17632141.png" alt="Icon" width="30" style="margin: 10px auto;">

           
            <!-- OTP -->
            <p style="color: #ff6f00; font-size: 18px; font-weight: bold; margin: 00px 0;">
              $otp
            </p>
            <p style="color: #777; font-size: 12px; margin: 10px 0;">
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

  void showMailSentDialog(BuildContext context) {
    setState(() {
      _isGoogleSignInInProgress = false;
    });
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
          textStyle: GoogleFonts.hammersmithOne(color: Colors.white),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Adjust sizes dynamically
    final iconSize =
        screenWidth * 0.08; // Adjust icon size based on screen width
    final titleFontSize = screenWidth * 0.1;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.075),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            // Check the swipe direction (down)
            if (details.velocity.pixelsPerSecond.dy > 500) {
              Navigator.pop(context);
            }
          },
          child: AppBar(
            toolbarHeight: screenHeight * 0.08,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.015, left: 10),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.arrowDown, size: iconSize),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Profile",
                    style: GoogleFonts.hammersmithOne(
                      fontSize: titleFontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .requestFocus(FocusNode()); // Unfocus the TextField
        },
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/test.jpg', // Replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
            // Background color or other widgets

            // Container on top left of screen
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: MediaQuery.of(context).size.height * 0.12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // Profile Picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 4, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        user?.photoURL ??
                            'https://res.cloudinary.com/dcrm8qosr/image/upload/v1740335403/logo.png',
                      ),
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  // User Name
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15), // Adjust padding as needed
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // White background
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      boxShadow: const [],
                    ),
                    child: changePassword == '0'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hey,",
                                    style: GoogleFonts.hammersmithOne(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 10, 10, 9),
                                    ),
                                  ),
                                  /* Container(
                                     width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    alignment: Alignment
                                        .centerLeft, // This ensures left alignment of the content
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        toTitleCase(user?.displayName ?? name!),
                                         style: GoogleFonts.hammersmithOne(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                          color: const Color.fromARGB(
                                              255, 10, 10, 9),
                                        ),
                                      ),
                                    ),
                                  ), */
                                  Text(
                                    toTitleCase(user?.displayName ?? name!),
                                    style: GoogleFonts.hammersmithOne(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                      color:
                                          const Color.fromARGB(255, 10, 10, 9),
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Handling overflow if needed
                                    softWrap:
                                        false, // Prevents text from wrapping
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Creating from: ${date!}",
                                    style: GoogleFonts.hammersmithOne(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        color: Colors.grey[500]),
                                  ),
                                  Text(
                                    user?.email ?? email!,
                                    style: GoogleFonts.hammersmithOne(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    changePassword = '1';
                                  });
                                  _confirmPasswordController.clear();
                                  _newPasswordController.clear();
                                  _currentPasswordController.clear();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent, // Blue color
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  'Change Password',
                                  style: GoogleFonts.hammersmithOne(
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              /* SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01), */

                              ElevatedButton(
                                onPressed: () async {
                                  bool confirmLogout = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm Logout"),
                                            content: Text(
                                                "Are you sure you want to logout?",
                                                style: GoogleFonts
                                                    .hammersmithOne()),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false); // Cancel
                                                },
                                                child: Text("No",
                                                    style: GoogleFonts
                                                        .hammersmithOne()),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true); // Confirm
                                                },
                                                child: Text("Yes",
                                                    style: GoogleFonts
                                                        .hammersmithOne()),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;

                                  if (confirmLogout) {
                                    // Logout logic
                                    await GoogleSignIn().signOut();
                                    await firebase_auth.FirebaseAuth.instance
                                        .signOut();
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool("isLoggedIn", false);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent, // Blue color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  "Logout",
                                  style: GoogleFonts.hammersmithOne(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : changePassword == '1'
                            ? Form(
                                key: _formKey,
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    //change password
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  changePassword = '0';
                                                });
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.arrowLeft,
                                                size: 18.sp,
                                                color: Colors.black,
                                              )),
                                          Text(
                                            'Change Password',
                                            style: GoogleFonts.hammersmithOne(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),

                                      // Current Password Field
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller:
                                                  _currentPasswordController,
                                                  
          obscureText: _obscureCurrentPassword,
                                              decoration: InputDecoration(
                                                labelText: 'Current Password',
                                                hintText:
                                                    'Enter your current password',
                                                labelStyle:
                                                    GoogleFonts.hammersmithOne(
                                                  color: Colors.black,
                                                  fontSize: 14.sp,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureCurrentPassword
                                                        ? HeroiconsMicro
                                                            .eyeSlash
                                                        : HeroiconsMicro.eye,
                                                    color: Colors.black,
                                                    size: 18.sp,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureCurrentPassword =
                                                          !_obscureCurrentPassword;
                                                    });
                                                  },
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey[50],
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.auto,
                                              ),
                                              style: GoogleFonts.hammersmithOne(
                                                fontSize: 14.sp,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Current password is required';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 10),

                                            // New Password Field
                                            TextFormField(
                                              controller:
                                                  _newPasswordController,
                                              obscureText: _obscureNewPassword,
                                              decoration: InputDecoration(
                                                labelText: 'New Password',
                                                hintText:
                                                    'Enter your new password',
                                                labelStyle:
                                                    GoogleFonts.hammersmithOne(
                                                  color: Colors.black,
                                                  fontSize: 14.sp,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                               suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? HeroiconsMicro
                                                            .eyeSlash
                                                        : HeroiconsMicro.eye,
                                                    color: Colors.black,
                                                    size: 18.sp,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureConfirmPassword =
                                                          !_obscureConfirmPassword;
                                                      _obscureNewPassword =
                                                          !_obscureNewPassword;
                                                    });
                                                  },
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey[50],
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.auto,
                                              ),
                                              style: GoogleFonts.hammersmithOne(
                                                fontSize: 14.sp,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Password is required';
                                                }
                                                if (value ==
                                                    _currentPasswordController
                                                        .text) {
                                                  return 'Password cannot be same as old';
                                                }
                                                if (value.length < 8) {
                                                  return 'Password must be at least 8 characters';
                                                }
                                                final regex = RegExp(
                                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
                                                if (!regex.hasMatch(value)) {
                                                  return 'Password requires uppercase, lowercase, number, and symbol';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 10),

                                            // Confirm Password Field
                                            TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              obscureText: _obscureConfirmPassword,
                                              decoration: InputDecoration(
                                                labelText: 'Confirm Password',
                                                hintText:
                                                    'Re-enter your new password',
                                                labelStyle:
                                                    GoogleFonts.hammersmithOne(
                                                  color: Colors.black,
                                                  fontSize: 14.sp,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ),
                                                
                                                filled: true,
                                                fillColor: Colors.grey[50],
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.auto,
                                              ),
                                              style: GoogleFonts.hammersmithOne(
                                                fontSize: 14.sp,
                                              ),
                                              validator: (value) {
                                                if (value !=
                                                    _newPasswordController
                                                        .text) {
                                                  return 'Passwords do not match';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 15),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      changePassword = '2';
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: const Size(100,
                                                        30), // Set a fixed width and height
                                                    backgroundColor: Colors.redAccent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    textStyle: GoogleFonts
                                                        .hammersmithOne(
                                                            fontSize: 16.sp),
                                                  ),
                                                  child: Text(
                                                    "Forgot password",
                                                    style: GoogleFonts
                                                        .hammersmithOne(
                                                            color: Colors.white,
                                                            fontSize: 13.sp),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              FocusNode()); // Unfocus the TextField

                                                      setState(() =>
                                                          _isSending = true);
                                                      // Validate Current Password with Supabase
                                                      final validateResponse =
                                                          await Supabase
                                                              .instance.client
                                                              .from('users')
                                                              .select(
                                                                  'email, password, name')
                                                              .eq(
                                                                  'email',
                                                                  email!
                                                                      .toLowerCase())
                                                              .eq(
                                                                  'password',
                                                                  _currentPasswordController
                                                                      .text);

                                                      if (validateResponse
                                                          .isEmpty) {
                                                        setState(() =>
                                                            _isSending = false);

                                                        const snackBar =
                                                            SnackBar(
                                                          elevation: 0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          content:
                                                              AwesomeSnackbarContent(
                                                            color: Colors.red,
                                                            title: 'Oh Snap!',
                                                            message:
                                                                'Invalid current password',
                                                            contentType:
                                                                ContentType
                                                                    .failure,
                                                            inMaterialBanner:
                                                                true,
                                                          ),
                                                        );
                                                        ScaffoldMessenger.of(
                                                            context)
                                                          ..hideCurrentSnackBar()
                                                          ..showSnackBar(
                                                              snackBar);

                                                        return;
                                                      }
                                                      setState(() =>
                                                          _isSending = false);

                                                      // Update Password in Supabase
                                                      final updateResponse =
                                                          await Supabase
                                                              .instance.client
                                                              .from('users')
                                                              .update({
                                                        'password':
                                                            _newPasswordController
                                                                .text
                                                      }).eq(
                                                                  'email',
                                                                  email!
                                                                      .toLowerCase());
                                                      setState(() {
                                                        changePassword = '0';
                                                      });
                                                      const snackBar = SnackBar(
                                                        elevation: 0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        content:
                                                            AwesomeSnackbarContent(
                                                          color: Colors.green,
                                                          title: 'Yay!',
                                                          message:
                                                              'Password changed successfully!',
                                                          contentType:
                                                              ContentType
                                                                  .success,
                                                          inMaterialBanner:
                                                              true,
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                          context)
                                                        ..hideCurrentSnackBar()
                                                        ..showSnackBar(
                                                            snackBar);
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: const Size(100,
                                                        30), // Set a fixed width and height
                                                    backgroundColor: Colors.redAccent,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    textStyle: GoogleFonts
                                                        .hammersmithOne(
                                                            fontSize: 16.sp),
                                                  ),
                                                  child: _isSending
                                                      ? LoadingAnimationWidget
                                                          .inkDrop(
                                                          size: screenWidth *
                                                              0.04,
                                                          color: Colors.white,
                                                        )
                                                      : Text(
                                                          'Confirm',
                                                          style: GoogleFonts
                                                              .hammersmithOne(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      13.sp),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                changePassword = '1';
                                              });
                                              _currentPasswordController
                                                  .clear();
                                              _newPasswordController.clear();
                                              _confirmPasswordController
                                                  .clear();
                                            },
                                            icon: Icon(
                                              FontAwesomeIcons.arrowLeft,
                                              size: 18.sp,
                                              color: Colors.black,
                                            )),
                                        Text(
                                          'Forgot Password',
                                          style: GoogleFonts.hammersmithOne(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    /* TextFormField(
                                      controller: _femailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'Enter your email address',
                                        labelStyle: GoogleFonts.hammersmithOne(
                                          color: Colors.black,
                                          fontSize: 14.sp,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[
                                                300]!, // Default border color
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[
                                                300]!, // Border color when focused
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[
                                                300]!, // Border color when not focused
                                          ),
                                        ),
                                        filled: true,
                                        fillColor:
                                            Colors.grey[50], // Background color
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                      ),
                                      style: GoogleFonts.hammersmithOne(
                                        fontSize: 14.sp, // Font size adjustment
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        // Check if email is empty
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        // Check if the email matches a specific email (replace 'email' with the desired email)
                                        if (value != email) {
                                          return 'Email does not match';
                                        }
                                        // Check if the email format is correct
                                        return null;
                                      },
                                    ), */
                                    Text(email!),
                                    SizedBox(height: screenHeight * 0.02),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _isGoogleSignInInProgress =
                                              true; // Set to true when the button is pressed
                                        });

                                        // Trigger form validation before calling `validateIfExists()`
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          vadlidateIfExists(); // Call your function here
                                        } else {
                                          setState(() {
                                            _isGoogleSignInInProgress =
                                                false; // Reset to false when validation fails
                                          });
                                        }
                                      },
                                      icon: _isGoogleSignInInProgress
                                          ? LoadingAnimationWidget.inkDrop(
                                              size: screenWidth * 0.04,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.mail,
                                              color: Colors.white,
                                            ),
                                      label: Text(
                                        'Send Email',
                                        style: GoogleFonts.hammersmithOne(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: screenWidth > 600
                                              ? screenWidth * 0.02
                                              : screenWidth * 0.025,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        minimumSize: Size(double.infinity,
                                            screenHeight * 0.04),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),

                  // Logout Button
                  const Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(width: 30),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Dummy data for the profile
  final String userName = "John Doe";
  final String email = "johndoe@example.com";
  final String profilePicUrl = "https://cdn-icons-png.flaticon.com/512/6717/6717652.png"; // Replace with your profile image URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F9),
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xFF5D4B8E), // Purple background
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Profile Picture on Top
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(profilePicUrl),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),

            // User Information in a List
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildListTile("Username", userName, Icons.person),
                  _buildListTile("Email", email, Icons.email),
                  _buildListTile(
                    "Change Password",
                    "Update your password",
                    Icons.lock,
                    onTap: () {
                     /*  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                      ); */
                    },
                  ),
                  _buildListTile(
                    "Deactivate Account",
                    "Temporarily deactivate your account",
                    Icons.remove_circle_outline,
                    onTap: () {
                    /*   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeactivateAccountPage()),
                      ); */
                    },
                  ),
                  _buildListTile(
                    "Delete Account",
                    "Permanently delete your account",
                    Icons.delete,
                    onTap: () {
                     /*  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                      ); */
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Log Out Button
            ElevatedButton(
              onPressed: () {
                // Add your log-out functionality here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Log Out"),
                    content: Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Log out logic goes here
                          // For example: Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text("Log Out"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5D4B8E), // Purple color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: Text(
                "Log Out",
                style: GoogleFonts.hammersmithOne(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create the ListTile widgets
  Widget _buildListTile(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF5D4B8E)),
        title: Text(title, style: GoogleFonts.hammersmithOne(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: GoogleFonts.hammersmithOne(fontSize: 14, color: Colors.grey[600])),
        onTap: onTap,
      ),
    );
  }
}
 */

class _SwipeableImagePage extends StatelessWidget {
  final String imageUrl;

  _SwipeableImagePage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ],
    );
  }
}
