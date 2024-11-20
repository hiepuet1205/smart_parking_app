import 'dart:io';
import 'package:dio/dio.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:first_app/widgets/custom-text-field.dart';
import 'package:first_app/widgets/select_drop_list.dart';
import 'package:first_app/model/drop_list_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final dio = Dio();
  bool _isLoading = true;

  Map<String, dynamic> info = {};
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
      _nameController.text = info['name'] ?? '';
      _emailController.text = info['email'] ?? '';
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

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> showImageSourceOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                getImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                getImageFromCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfile() async {
    // if (_image == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please select an image')),
    //   );
    //   return;
    // }

    // try {
    //   setState(() => _isLoading = true);

    //   FormData formData = FormData.fromMap({
    //     'fullName': _fullNameController.text,
    //     'role': selectedRole.title,
    //     'shortDescription': _shortDescriptionController.text,
    //     'file': await MultipartFile.fromFile(_image!.path, filename: 'profile_image.jpg'),
    //   });

    //   // Replace 'your_api_url' with the actual API endpoint
    //   Response response = await dio.put('your_api_url/profile', data: formData);

    //   if (response.statusCode == 200) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Profile updated successfully')),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Failed to update profile')),
    //     );
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error: $e')),
    //   );
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: const CustomAppBar(title: 'Edit Profile'),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _image == null
                          ? CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(info['avatar'] ?? ''),
                            )
                          : CircleAvatar(
                              radius: 100,
                              backgroundImage: FileImage(_image!),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => showImageSourceOptions(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Change Photo', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Name',
                      controller: _nameController,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Email',
                      controller: _emailController,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
