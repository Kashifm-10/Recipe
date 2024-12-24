import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:recipe/pages/biggerScreens/home.dart';
import 'package:recipe/pages/loginPage.dart';
import 'package:recipe/pages/smallScreens/s_home.dart';
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
     Timer(const Duration(milliseconds: 3500), () {
      if (isLoggedIn!) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MediaQuery.of(context).size.width > 600
                  ? const MyHomePage()
                  : const MySmallHomePage()),
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

      body: Stack(
  children: [
    // Background image
    Positioned.fill(
      child: Image.asset(
        'assets/images/splash.png',
        fit: BoxFit.cover,
      ),
    ),
    // Lottie animation in the center
    Positioned(
      top: screenWidth<600 ? screenHeight *0.15: screenHeight*0.07, // You can adjust this value for the desired vertical offset
      left: (screenWidth - screenWidth * 0.9) / 2, // To center it horizontally
      child: Lottie.asset(
        'assets/lottie_json/splash.json',
        width: screenWidth * 0.9,
      ),
    ),
Positioned(
      top: screenWidth<600 ?screenHeight *0.3:screenHeight*0.22, // You can adjust this value for the desired vertical offset
      left: (screenWidth * 0.1) , // To center it horizontally
      child: Lottie.asset(
        'assets/lottie_json/splashload.json',
        width: screenWidth * 0.8,
      ),
    ),
  ],
),

    );
  }
}
