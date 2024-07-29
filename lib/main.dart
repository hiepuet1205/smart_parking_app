import 'package:first_app/screens/signup.screen.dart';
import 'package:first_app/widgets/base-screen.dart';
import 'package:flutter/material.dart';

import 'screens/signin.screen.dart';

void main() {
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // '/': (context) => const SignUpScreen(),
        '/': (context) => const BaseScreen(),
        '/sign-in': (context) => const SignInScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
