import 'package:dio/dio.dart';
import 'package:first_app/screens/vehicle/add-vehicle.screen.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/base-screen.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/vehicle-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListVehicleScreen extends ConsumerStatefulWidget {
  const ListVehicleScreen({super.key});

  @override
  _ListVehicleScreenState createState() => _ListVehicleScreenState();
}

class _ListVehicleScreenState extends ConsumerState<ListVehicleScreen> {
  List<Map<String, dynamic>> vehicles = [];
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
      await _fetchVehicles();
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVehicles() async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/vehicles',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>>' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(response.data);
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

  void onTap(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Vehicle'),
      backgroundColor: const Color(0xFF16191D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return VehicleCard(
                  id: vehicle['id']!,
                  licensePlate: vehicle['licensePlates']!,
                  type: vehicle['type']!,
                  image: vehicle['image']!,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onTap(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
