import 'package:first_app/widgets/base-auth.dart';
import 'package:first_app/widgets/signin-form.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return const BaseAuthWidget('sign-in', SignInForm());
  }
}
