import 'dart:io';

import 'package:dio/dio.dart';
import 'package:first_app/model/drop_list_model.dart';
import 'package:first_app/screens/vehicle/list-vehicle.screen.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/custom-text-field.dart';
import 'package:first_app/widgets/select_drop_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class EditVehicleScreen extends StatefulWidget {
  final int id;

  const EditVehicleScreen({super.key, required this.id});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  File? _image;
  final picker = ImagePicker();
  late int _id;

  final TextEditingController _lisensePlateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  DropListModel dropListModel = DropListModel(
      [OptionItem(id: "1", title: "CAR"), OptionItem(id: "2", title: "MOTO")]);
  OptionItem optionItemSelected = OptionItem(id: "1", title: "CAR");

  bool _isLoading = true;
  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    print("_id: " + _id.toString());

    _initializeState();
  }

  Map<String, dynamic> vehicle = {};

  Future<void> _initializeState() async {
    try {
      await _fetchVehicleById(_id);
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicleById(int id) async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/vehicles/$id',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>>' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          vehicle = Map<String, dynamic>.from(response.data);

          _lisensePlateController.text = vehicle['licensePlates'] ?? '';

          final typeValue = vehicle['type'] ?? 'CAR';
          optionItemSelected = dropListModel.listOptionItems.firstWhere(
            (item) => item.title == typeValue,
            orElse: () => OptionItem(id: "1", title: "CAR"),
          );

          _typeController.text = optionItemSelected.title;

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

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> showOptions(BuildContext context) async {
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

  Future<void> _updateVehicle() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      FormData formData = FormData.fromMap({
        'licensePlates': _lisensePlateController.text,
        'type': optionItemSelected.title,
        'file': await MultipartFile.fromFile(_image!.path,
            filename: 'vehicle_image.jpg'),
      });

      print('FormData: ${formData.fields}');

      Response response = await dio.put(
        '${apiUrl}api/v1/vehicles/$_id',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Content-Type': 'multipart/form-data',
            'Cookie': cookies ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListVehicleScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add vehicle')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16191D),
      appBar: const CustomAppBar(title: 'Edit Vehicle'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Thêm SingleChildScrollView ở đây
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      hintText: 'Lisense Plate',
                      controller: _lisensePlateController,
                    ),
                    const SizedBox(height: 16),
                    SelectDropList(
                      optionItemSelected,
                      dropListModel,
                      (OptionItem option) {
                        setState(() {
                          optionItemSelected = option;
                          _typeController.text = option.title as String;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _image == null
                          ? Image.network(
                              vehicle['image']!,
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            )
                          : Image.file(
                              _image!,
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showOptions(context);
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Select Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _updateVehicle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Update vehicle',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Colors.red, width: 3),
                      ),
                      child: const Text('Delete vehicle',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
