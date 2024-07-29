import 'package:first_app/widgets/base-auth.dart';
import 'package:first_app/widgets/signup-form.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return const BaseAuthWidget('sign-up', SignUpForm());
  }
}
