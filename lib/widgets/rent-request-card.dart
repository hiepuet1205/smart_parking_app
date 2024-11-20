import 'package:first_app/screens/map/direction.screen.dart';
import 'package:flutter/material.dart';

class RentRequestCard extends StatelessWidget {
  final String id;
  final String startTime;
  final String endTime;
  final int pricePerHour;
  final int depositAmount;
  final double long;
  final double lat;

  const RentRequestCard(
      {super.key,
      required this.id,
      required this.startTime,
      required this.endTime,
      required this.pricePerHour,
      required this.depositAmount,
      required this.long,
      required this.lat});

  void onTap(context) {
    print('long' + long.toString());
    print('lat' + lat.toString());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapView(
          destinationLatitude: lat,
          destinationLongitude: long,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(context);
      },
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
                    Text(
                      startTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      endTime,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        backgroundColor: const Color(0xFF5F4B34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        side: const BorderSide(
                            color: Color(0xFFFFB560), width: 3)),
                    child: Text('${depositAmount.round().toString()} m',
                        style: const TextStyle(color: Color(0xFFFFB560))),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 30),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
