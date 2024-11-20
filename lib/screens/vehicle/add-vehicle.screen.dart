import 'dart:io';

import 'package:dio/dio.dart';
import 'package:first_app/model/drop_list_model.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/custom-text-field.dart';
import 'package:first_app/widgets/select_drop_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _lisensePlateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];
  DropListModel dropListModel = DropListModel(
      [OptionItem(id: "1", title: "CAR"), OptionItem(id: "2", title: "MOTO")]);
  OptionItem optionItemSelected = OptionItem(id: "1", title: "CAR");

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

  Future<void> _addVehicle() async {
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

      Response response = await dio.post(
        '${apiUrl}api/v1/vehicles',
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
      appBar: const CustomAppBar(title: 'Add Vehicle'),
      body: Padding(
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
                        'https://fastly.picsum.photos/id/733/200/300.jpg?hmac=JYkTVVdGOo8BnLPxu1zWliHFvwXKurY-uTov5YiuX2s',
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      )
                    : Image.file(
                        _image!,
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      )),
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
            ElevatedButton.icon(
              onPressed: _addVehicle,
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
