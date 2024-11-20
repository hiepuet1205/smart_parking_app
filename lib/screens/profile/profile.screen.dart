import 'package:dio/dio.dart';
import 'package:first_app/screens/profile/change-password.dart';
import 'package:first_app/screens/profile/edit-profile.screen.dart';
import 'package:first_app/screens/signin.screen.dart';
import 'package:first_app/screens/vehicle/list-vehicle.screen.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic> info = {};
  bool _isLoading = true;
  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      await _fetchInfo();
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchInfo() async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/users/info',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          info = Map<String, dynamic>.from(response.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('API call error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: const CustomAppBar(title: 'My Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Row(
                    children: [
                      info['avatar'] == null
                          ? CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 30),
                            )
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(info['avatar']),
                              backgroundColor: Colors.transparent,
                            ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['name'] ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            info['email'] ?? '',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.grey[700]),

                  // Menu Options
                  SizedBox(height: 10),
                  ListTile(
                    title: Text('Change Password',
                        style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[700]),
                  ListTile(
                    title: Text('Edit Profile',
                        style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[700]),
                  ListTile(
                    title:
                        Text('Vehicles', style: TextStyle(color: Colors.white)),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListVehicleScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(color: Colors.grey[700]),

                  // Log Out Button
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey[800], // Text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      child: Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
