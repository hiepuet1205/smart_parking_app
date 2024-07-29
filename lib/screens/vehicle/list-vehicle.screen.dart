import 'package:first_app/widgets/custom-app-bar.dart';
import 'package:first_app/widgets/vehicle-card.dart';
import 'package:flutter/material.dart';

class ListVehicleScreen extends StatefulWidget {
  const ListVehicleScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListVehicleScreenState();
}

class _ListVehicleScreenState extends State<ListVehicleScreen> {
  final List<Map<String, String>> vehicles = [
    {
      'name': 'BMW',
      'licensePlate': '--',
      'type': 'bmw',
      'image':
          'https://fastly.picsum.photos/id/733/200/300.jpg?hmac=JYkTVVdGOo8BnLPxu1zWliHFvwXKurY-uTov5YiuX2s', // Replace with actual URL
    },
    {
      'name': 'BMW',
      'licensePlate': '--',
      'type': 'bmw',
      'image':
          'https://fastly.picsum.photos/id/733/200/300.jpg?hmac=JYkTVVdGOo8BnLPxu1zWliHFvwXKurY-uTov5YiuX2s', // Replace with actual URL
    },
    {
      'name': 'BMW',
      'licensePlate': '--',
      'type': 'bmw',
      'image':
          'https://fastly.picsum.photos/id/733/200/300.jpg?hmac=JYkTVVdGOo8BnLPxu1zWliHFvwXKurY-uTov5YiuX2s', // Replace with actual URL
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Vehicle'),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return VehicleCard(
            name: vehicle['name']!,
            licensePlate: vehicle['licensePlate']!,
            type: vehicle['type']!,
            image: vehicle['image']!,
          );
        },
      ),
    );
  }
}
