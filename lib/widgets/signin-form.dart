import 'package:first_app/widgets/custom-text-field.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<StatefulWidget> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  @override
  Widget build(BuildContext context) {
    return Center(  // Thêm widget Center
      child: ListView(
        shrinkWrap: true,  // Đảm bảo ListView có kích thước nhỏ nhất
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          const SizedBox(height: 10.0),
          const CustomTextField(hintText: 'Email'),
          const SizedBox(height: 10.0),
          const CustomTextField(
            hintText: 'Password',
            obscureText: true,
            suffixIcon: Icons.visibility_off,
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Create Account'),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Forgot Password'),
          ),
        ],
      ),
    );
  }
}
