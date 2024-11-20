import 'package:first_app/screens/request/create-request.screen.dart';
import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final String id;
  final String image;
  final String extractLocation;
  final int priceHour;

  const SlotCard({
    super.key,
    required this.id,
    required this.image,
    required this.extractLocation,
    required this.priceHour,
  });

  void onTap(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRequestScreen(slotId: id,),
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
                      extractLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      'available',
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
                    child: Text('${priceHour.toString()} đ/h',
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
