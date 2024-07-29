import 'package:first_app/screens/signin.screen.dart';
import 'package:first_app/widgets/overlay-background.dart';
import 'package:first_app/widgets/signin-form.dart';
import 'package:first_app/widgets/signup-form.dart';
import 'package:flutter/material.dart';

import '../screens/signup.screen.dart';

class BaseAuthWidget extends StatefulWidget {
  final String screen;
  final Widget child;

  const BaseAuthWidget(this.screen, this.child, {super.key});

  @override
  State<BaseAuthWidget> createState() => _BaseAuthWidgetState();
}

class _BaseAuthWidgetState extends State<BaseAuthWidget> {
  bool isSignIn = true;

  void toggleScreen(bool signIn) {
    if (isSignIn != signIn) {
      setState(() {
        isSignIn = signIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverlayBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.car_crash,
                    size: 48.0,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Parking App',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.white,
                  ),
                ),
              ]),
              const SizedBox(height: 10.0),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                  'Access your account or create a new one below.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OutlinedButton(
                    onPressed: () => toggleScreen(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          width: 3,
                          color: isSignIn ? Color(0xFF27292a) : Color(0xFF1E88E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: isSignIn
                          ? Color(0xFF27282a).withOpacity(0.5)
                          : Colors.blue.shade300.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: isSignIn ? Colors.grey : Colors.white,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () => toggleScreen(true),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          width: 3,
                          color: isSignIn ? Color(0xFF1E88E5) : Color(0xFF27292a)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: isSignIn
                          ? Color.fromARGB(216, 100, 180, 246).withOpacity(0.5)
                          : Color(0xFF27282a).withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          color: isSignIn ? Colors.white : Colors.grey,
                          fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isSignIn
                    ? const SignInForm(key: ValueKey('signIn'))
                    : const SignUpForm(key: ValueKey('signUp')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
