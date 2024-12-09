import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/biggerScreens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
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
          .select('email') // Only check for the email field
          .eq('email', userEmail);

      // Convert the response to a list of maps
      final data = List<Map<String, dynamic>>.from(response);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);

      if (data.isEmpty) {
        // Email is not taken, proceed with registration
        try {
          final userResponse =
              await Supabase.instance.client.from('users').insert([
            {
              'name': userName,
              'email': userEmail,
              'password':
                  '', // No password needed for Google sign-in, or set a placeholder
            }
          ]);

          // Handle success

          // Save user email and username to SharedPreferences
          await prefs.setString('user_email', userEmail);
          await prefs.setString('user_name', userName);

          // Optionally navigate to home screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
      // Navigate to a new page after successful login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Google sign-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: No Internet Connection')));
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
