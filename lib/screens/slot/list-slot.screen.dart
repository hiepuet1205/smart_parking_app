import 'package:dio/dio.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/slot-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListSlotScreen extends ConsumerStatefulWidget {
  final String locationId;

  const ListSlotScreen({super.key, required this.locationId});

  @override
  _ListSlotScreenState createState() => _ListSlotScreenState();
}

class _ListSlotScreenState extends ConsumerState<ListSlotScreen> {
  List<Map<String, dynamic>> _slots = [];
  bool _isLoading = true;
  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];
  String locationId = '0';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locationId = widget.locationId;
    _initializeState(); // Gọi hàm async từ initState
    _searchController.addListener(() {
      // _filterSlots(); // Có thể triển khai sau nếu cần
    });
  }

  Future<void> _initializeState() async {
    try {
      await _fetchSlots();
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSlots() async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/parking-slots/$locationId',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>>' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          _slots = List<Map<String, dynamic>>.from(response.data);
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
      appBar: const CustomAppBar(title: 'Slot'),
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
                      hintText: 'Search slot here',
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
                    itemCount: _slots.length,
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      return SlotCard(
                        id: slot['id'].toString(),
                        image: slot['image'],
                        extractLocation: slot['extractLocation'],
                        priceHour: slot['priceHour'],
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
