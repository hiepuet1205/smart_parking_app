import 'package:first_app/screens/signin.screen.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:flutter/material.dart';
import 'package:first_app/widgets/custom-text-field.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];

  final dio = Dio();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      PanaraInfoDialog.show(
        context,
        title: "Error",
        message: "New password and confirm password do not match",
        buttonText: "Okay",
        onTapDismiss: () {
          Navigator.pop(context);
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Response response = await dio.put(
        '${apiUrl}api/v1/users/change-password',
        data: {
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
        options: Options(headers: {
          'Cookie': cookies ?? '',
        }, validateStatus: (status) => status! < 500),
      );


      if (response.statusCode == 200) {
        PanaraInfoDialog.show(
          context,
          title: "Success",
          message: "Password changed successfully",
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: const CustomAppBar(title: 'Change Password'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    hintText: 'Old Password',
                    controller: _oldPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'New Password',
                    controller: _newPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Confirm New Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 15),
                    ),
                    child: const Text(
                      "Change Password",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
