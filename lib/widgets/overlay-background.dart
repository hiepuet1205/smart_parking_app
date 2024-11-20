import 'package:flutter/material.dart';

class OverlayBackground extends StatelessWidget {
  final Widget child;

  const OverlayBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.5),
        ),
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        )
      ],
    );
  }
}
