import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/widgets/custom-text-field.dart';
import '../shared/cookie_storage.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<StatefulWidget> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final dio = Dio();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;
    final apiUrl = dotenv.env['API_URL'];

    try {
      final response = await dio.post(
        '${apiUrl}api/v1/auths/login',
        data: jsonEncode({'email': email, 'password': password}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        final rawCookies = response.headers['set-cookie'];
        if (rawCookies != null && rawCookies.isNotEmpty) {
          CookieStorage().storeCookies(rawCookies);
        }

        Navigator.pushNamed(context, '/home');
      } else {
        _showErrorDialog('Login failed: ${response.data['message']}');
      }
    } catch (e) {
      print(e);
      _showErrorDialog('Something went wrong. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
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
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
