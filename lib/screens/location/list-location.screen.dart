import 'package:first_app/shared/cookie_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/location-card.dart';
import 'package:geolocator/geolocator.dart';

class ListLocationScreen extends ConsumerStatefulWidget {
  const ListLocationScreen({super.key});

  @override
  _ListLocationScreenState createState() => _ListLocationScreenState();
}

class _ListLocationScreenState extends ConsumerState<ListLocationScreen> {
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;
  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeState(); // Gọi hàm async từ initState
    _searchController.addListener(() {
      // _filterLocations(); // Có thể triển khai sau nếu cần
    });
  }

  Future<void> _initializeState() async {
    try {
      Position location = await _determinePosition();
      print('>>>>>>>>>>>>>>>>>>' + location.toString());
      await _fetchLocations(location.latitude, location.longitude);
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchLocations(double latitude, double longitude) async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/locations/range',
        queryParameters: {'lat': latitude, 'long': longitude, 'radius': 1000},
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>>' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          _locations = List<Map<String, dynamic>>.from(response.data);
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
      appBar: const CustomAppBar(title: 'Location'),
      backgroundColor: const Color(0xFF16191D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location here',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final location = _locations[index];
                      return LocationCard(
                        id: location['id'].toString(),
                        name: location['name'],
                        location: location['location'],
                        price: location['minPrice'].toString(),
                        distance: location['distance'],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
