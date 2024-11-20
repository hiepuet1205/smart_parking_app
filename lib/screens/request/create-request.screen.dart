import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:first_app/screens/request/list-request.screen.dart';
import 'package:first_app/shared/cookie_storage.dart';
import 'package:first_app/widgets/vehicle-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datatTimePicker;
import 'package:uuid/uuid.dart';
import 'package:vnpay_flutter/vnpay_flutter.dart';

class CreateRequestScreen extends StatefulWidget {
  final String slotId;

  const CreateRequestScreen({super.key, required this.slotId});

  @override
  _CreateRequestScreenState createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 1));

  late final String _slotId;
  bool _isLoading = true;
  final dio = Dio();
  final cookies = CookieStorage().getCookies();
  final apiUrl = dotenv.env['API_URL'];
  Map<String, dynamic> _slot = {};
  List<Map<String, dynamic>> vehicles = [];
  double totalCost = 0.0;
  Map<String, dynamic>? selectedVehicle;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _slotId = widget.slotId;
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      await _fetchSlotById(_slotId);
      _calculateTotalCost();
      await _fetchVehicles();
    } catch (e) {
      print('Error initializing state: $e');
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSlotById(String slotId) async {
    try {
      final response = await dio.get(
        '${apiUrl}api/v1/parking-slots/slot/$slotId',
        options: Options(
          headers: {
            'Cookie': cookies ?? '',
          },
        ),
      );

      print('>>>>>>>>>>>>>>>>>>>>>' + response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          _slot = Map<String, dynamic>.from(response.data);
          print('Slot: $_slot');
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

  Future<void> _selectDateTime(
      BuildContext context, bool isStartDateTime) async {
    datatTimePicker.DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365)),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          if (isStartDateTime) {
            _startDateTime = DateTime(
                date.year, date.month, date.day, date.hour, date.minute);
          } else {
            _endDateTime = DateTime(
                date.year, date.month, date.day, date.hour, date.minute);
          }
          _calculateTotalCost();
        });
      },
      currentTime: isStartDateTime ? _startDateTime : _endDateTime,
      locale: datatTimePicker.LocaleType.en,
    );
  }

  void _calculateTotalCost() {
    if (_slot.isNotEmpty && _slot['priceHour'] != null) {
      // Lấy sự khác biệt thời gian và chỉ tính đến phút
      final minutes = _endDateTime.difference(_startDateTime).inMinutes;
      final pricePerHour = double.parse(_slot['priceHour'].toString());

      setState(() {
        // Tính tổng chi phí dựa trên số phút, chia cho 60 để ra số giờ
        totalCost = (minutes / 60) * pricePerHour;
      });
    }
  }

  Future<void> onPayment(String txnRef) async {
    print('${dotenv.env['VNP_TMNCODE']} ${dotenv.env['VNP_HASHKEY']}');

    String formattedAmount =
        NumberFormat('#,###', 'vi_VN').format(totalCost.round());

    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
        url: dotenv.env[
            'VNP_HOST']!, //vnpay url, default is https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
        version: '2.0.1',
        tmnCode: dotenv.env['VNP_TMNCODE']!, //vnpay tmn code, get from vnpay
        txnRef: txnRef,
        orderInfo:
            'Pay $formattedAmount VND', //order info, default is Pay Order
        amount: double.parse(totalCost.toStringAsFixed(0)),
        returnUrl:
            'https://abc.com/return', //https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/#code-returnurl
        ipAdress: '192.168.10.10',
        vnpayHashKey:
            dotenv.env['VNP_HASHKEY']!, //vnpay hash key, get from vnpay
        vnPayHashType: VNPayHashType
            .HMACSHA512, //hash type. Default is HmacSHA512, you can chang it in: https://sandbox.vnpayment.vn/merchantv2
        vnpayExpireDate: DateTime.now().add(Duration(days: 1)));
    VNPAYFlutter.instance.show(
      paymentUrl: paymentUrl,
      onPaymentSuccess: (params) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListRentRequestScreen(),
          ),
        );
      },
      onPaymentError: (params) {
        // setState(() {
        //   responseCode = 'Error';
        // });
      },
    );
  }

  Future<void> createRentRequest(String txnRef) async {
    print('>>>>>>>>>>>>>>>>>>>>>>> create rent request txnRef: $txnRef');
    try {
      final response = await dio.post(
        '${apiUrl}api/v1/rent-requests/',
        data: jsonEncode({
          'slotId': _slotId,
          'vehicleId': selectedVehicle?['id'],
          'startTime': _startDateTime.toIso8601String(), // Convert to String
          'endTime': _endDateTime.toIso8601String(), // Convert to String
          'pricePerHour': _slot['priceHour'],
          'depositAmount': totalCost.toStringAsFixed(0),
          'txnRef': txnRef
        }),
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

  Future<void> checkout() async {
    String txnRef = uuid.v4();

    await createRentRequest(txnRef);
    await onPayment(txnRef);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('kk:mm').format(dateTime);
  }

  void _setSelectedVehicle(Map<String, dynamic> vehicle) {
    setState(() {
      selectedVehicle = vehicle;
    });

    print('Selected vehicle: $selectedVehicle');

    Navigator.pop(context);
  }

  // Hàm hiển thị danh sách vehicles
  void _showVehicleList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Select Vehicle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return VehicleCard(
                          id: vehicle['id']!,
                          licensePlate: vehicle['licensePlates']!,
                          type: vehicle['type']!,
                          image: vehicle['image']!,
                          onSelect: () => _setSelectedVehicle(vehicle),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve Spot'),
      ),
      backgroundColor: const Color(0xFF16191D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Parking Rate:",
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                "\$${_slot['priceHour']} đ / h",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _slot['extractLocation'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            _slot['location'] != null &&
                                    _slot['location']['location'] != null
                                ? _slot['location']['location']!
                                : 'Unknown location',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                        ],
                      ),
                    )
                  ]),
                  const SizedBox(height: 16),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Your Parking Total',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                        '${NumberFormat('#,###', 'vi_VN').format(totalCost.round())} đ',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white)),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () => {_selectDateTime(context, true)},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              const Text('Start Time',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              Text(_formatTime(_startDateTime),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              Text(_formatDate(_startDateTime),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ],
                          )),
                      ElevatedButton(
                          onPressed: () => {_selectDateTime(context, false)},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              const Text('End Time',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              Text(_formatTime(_endDateTime),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              Text(_formatDate(_endDateTime),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ],
                          ))
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Vehicle Information',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 20),
                  selectedVehicle != null
                      ? VehicleCard(
                          id: selectedVehicle?['id'],
                          licensePlate: selectedVehicle?['licensePlates'],
                          type: selectedVehicle?['type'],
                          image: selectedVehicle?['image'],
                          onSelect: () => {},
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showVehicleList(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Add Vehicle',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: checkout,
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
