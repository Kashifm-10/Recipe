import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recipe/pages/home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MyHomePage(title: 'Recipes'),
      ));
    });
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
          'assets/images/splash_screen.png',
          // Make the image responsive to screen size
          width: screenWidth, // Scale width to 70% of screen width
          height: screenHeight , // Scale height to 40% of screen height
          fit: BoxFit.contain, // Ensures the image maintains aspect ratio
        ),
      ),
    );
  }
}
