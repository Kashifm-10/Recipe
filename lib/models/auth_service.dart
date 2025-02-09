import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:recipe/pages/smallScreens/s_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AuthService {
  String generateRandomPassword() {
    const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String specialChars = '@#%^&*!()_+[]{}|;:,.<>?';

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

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If the sign-in is successful, fetch authentication details
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // Create credentials for Firebase
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Print the email of the signed-in user
      print('User email: ${userCredential.user?.email}');
      final String userEmail = gUser.email;
      final String userName = gUser.displayName ??
          'No Name'; // Use the display name or a default if not available

      // Check if the email is already registered in Supabase
      final response = await Supabase.instance.client
          .from('users')
          .select('email, access, date') // Only check for the email field
          .eq('email', userEmail);

      // Convert the response to a list of maps
      final data = List<Map<String, dynamic>>.from(response);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (data.isNotEmpty) {
        String access = data.first['access'];
        String date = data.first['date'];
        
        await prefs.setString('email', userEmail);
        await prefs.setString('name', userName);
        await prefs.setString('access', access);
        await prefs.setString('date', date);
        await prefs.setBool("isLoggedIn", true);
      }
      if (data.isEmpty) {
        String password = generateRandomPassword();
        // Email is not taken, proceed with registration
        try {
          final userResponse =
              await Supabase.instance.client.from('users').insert([
            {
              'name': userName,
              'email': userEmail.toLowerCase(),
              'date':
                  (DateFormat('dd-MM-yyyy').format(DateTime.now())).toString(),
              'access': false,
              'password':
                  password, // No password needed for Google sign-in, or set a placeholder
            }
          ]);

          // Handle success

          // Save user email and username to SharedPreferences
          await prefs.setString('email', userEmail);
          await prefs.setString('name', userName);

          // Optionally navigate to home screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MediaQuery.of(context).size.width > 600
                    ? const MyHomePage()
                    : const MySmallHomePage()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          print('Error: $e');
          var snackBar = SnackBar(
            /// need to set following properties for best effect of awesome_snackbar_content
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              color: Colors.red,
              title: 'Login failed!',
              message: 'Something went wrong $e',

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
      // Navigate to a new page after successful login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MediaQuery.of(context).size.width > 600
                ? const MyHomePage()
                : const MySmallHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Google sign-in error: $e");
      var snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Colors.red,
          title: 'Login failed!',
          message: 'Something went wrong $e',

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

  // Log out the user
  Future<void> signOut(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Sign out from Google
      await GoogleSignIn().signOut();

      // Navigate back to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Sign-out error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }
}
