import 'package:first_app/screens/vehicle/edit-vehicle.screen.dart';
import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final int id;
  final String licensePlate;
  final String type;
  final String image;
  final VoidCallback? onSelect;

  const VehicleCard({
    super.key,
    required this.id,
    required this.licensePlate,
    required this.type,
    required this.image,
    this.onSelect,
  });

  void onTap(context) {
    if (onSelect != null) {
      onSelect!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVehicleScreen(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(context);
      }, // Xử lý onPress
      child: Card(
        color: const Color(0xFF1A1D17),
        shadowColor: const Color(0xFF131619),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: Color(0xFF1E88E5), width: 5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   name,
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 5.0),
                    Text(
                      licensePlate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  image,
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
