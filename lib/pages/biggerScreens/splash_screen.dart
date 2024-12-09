import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/biggerScreens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loginCheck();
    // Extend content to the edges (under status bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Hide the navigation bar but keep the status bar stretched
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    // Navigate to the home page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn!) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  void loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: screenWidth, // Make the image responsive to screen size
          height: screenHeight, // Scale height to 100% of screen height
          fit: BoxFit.cover, // Ensures the image maintains aspect ratio
        ),
      ),
    );
  }
}
