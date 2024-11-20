import 'dart:convert';
import 'package:first_app/screens/signin.screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:first_app/widgets/custom-text-field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  final dio = Dio();

  Future<void> _SignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      PanaraInfoDialog.show(
        context,
        title: "Error",
        message: "Password and confirm password do not match",
        buttonText: "Okay",
        onTapDismiss: () {
          Navigator.pop(context);
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final apiUrl = dotenv.env['API_URL'];

    try {
      final response = await dio.post(
        '${apiUrl}api/v1/users/sign-up',
        data: jsonEncode({'name': name, 'email': email, 'password': password}),
        options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status! < 500),
      );

      print('Response Headers: ${response.headers}');

      if (response.statusCode == 201) {
        PanaraInfoDialog.show(
          context,
          title: "Success",
          message: "Congratulations! You have signed up successfully",
          buttonText: "Okay",
          onTapDismiss: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInScreen(),
              ),
            );
          },
          panaraDialogType: PanaraDialogType.success,
          barrierDismissible: false,
        );
      } else {
        PanaraInfoDialog.show(
          context,
          title: "Error",
          message: response.data['message'],
          buttonText: "Okay",
          onTapDismiss: () {
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          const SizedBox(height: 10.0),
          CustomTextField(hintText: 'Name', controller: _nameController),
          const SizedBox(height: 10.0),
          CustomTextField(hintText: 'Email', controller: _emailController),
          const SizedBox(height: 10.0),
          CustomTextField(
            hintText: 'Password',
            obscureText: true,
            suffixIcon: Icons.visibility_off,
            controller: _passwordController,
          ),
          const SizedBox(height: 10.0),
          CustomTextField(
            hintText: 'Confirm New Password',
            obscureText: true,
            suffixIcon: Icons.visibility_off,
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _SignUp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
