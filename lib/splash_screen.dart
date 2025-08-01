import 'package:flutter/material.dart';
import 'package:spendly/main.dart'; // Import your main app file

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 3000), () {}); // Simulate a loading time
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to your main app widget
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000C23), // Match your original splash color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Image.asset('assets/images/splash_icon.png', height: 150),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0), // Adjust padding as needed
              child: Column(
                children: [
                  Text(
                    'I Love You ❤️',
                    style: TextStyle(color: Colors.white, fontSize: 14), // Reduced font size
                  ),
                  Text(
                    'Special Version',
                    style: TextStyle(color: Colors.white, fontSize: 14), // Reduced font size
                  ),
                  Text(
                    'Developed By Heaven Sarder',
                    style: TextStyle(color: Colors.white, fontSize: 12), // Reduced font size
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