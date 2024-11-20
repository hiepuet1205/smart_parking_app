import 'dart:ffi';

import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/rent-request-card.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:first_app/widgets/custom-app-bar.dart';

class ListRentRequestScreen extends ConsumerStatefulWidget {
  const ListRentRequestScreen({super.key});

  @override
  _ListRentRequestScreenState createState() => _ListRentRequestScreenState();
}

class _ListRentRequestScreenState extends ConsumerState<ListRentRequestScreen> {
  List<Map<String, dynamic>> _rentRequests = [];
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
      // _filterRentRequests(); // Có thể triển khai sau nếu cần
    });
  }

  Future<void> _initializeState() async {
    try {
      await _fetchRentRequests();
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRentRequests() async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/rent-requests/',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>> avc' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          _rentRequests = List<Map<String, dynamic>>.from(response.data);
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
      appBar: const CustomAppBar(title: 'Rent Request'),
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
                      hintText: 'Search rent request here',
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
                    itemCount: _rentRequests.length,
                    itemBuilder: (context, index) {
                      final rentRequest = _rentRequests[index];
                      print('rentRequest' + rentRequest['slot']['location']['long'].toString());
                      return RentRequestCard(
                        id: rentRequest['id'].toString(),
                        startTime: rentRequest['startTime'],
                        endTime: rentRequest['endTime'],
                        pricePerHour: rentRequest['pricePerHour'],
                        depositAmount: rentRequest['depositAmount'],
                        long: (rentRequest['slot']['location'] != null &&
                                rentRequest['slot']['location']['long'] != null)
                            ? double.parse(
                                rentRequest['slot']['location']['long'].toString())
                            : 0.0,
                        lat: (rentRequest['slot']['location'] != null &&
                                rentRequest['slot']['location']['lat'] != null)
                            ? double.parse(
                                rentRequest['slot']['location']['lat'].toString())
                            : 0.0,
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
