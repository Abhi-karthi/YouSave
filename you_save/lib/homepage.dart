import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'select_age.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 15.0),
                  ElevatedButton(
                    onPressed: () {
                      print('pressed');
                    },
                    child: Icon(Icons.menu, size: 24.0),
                  ),
                ],
              ),
              Text(
                'YOU SAVE',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                  fontSize: 52.0,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Every Beat Counts',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 170),

              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectAgePage()),
                  );
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.92 : 1.0, // Shrinks to 92% size
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Your heart shape code
                      const Icon(
                        Icons.favorite,
                        color: Color.fromARGB(255, 255, 61, 61),
                        size: 350,
                      ),
                      // Your ECG Painter code
                      SizedBox(
                        width: 93,
                        height: 170,
                        child: CustomPaint(painter: ECGLinesPainter()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ECGLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors
          .white // White line to contrast with your red heart
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double w = size.width;
    double h = size.height;
    double mid = h / 2;

    // Starting Baseline
    path.moveTo(w * 0.1, mid);
    // path.lineTo(w * 0.1, mid);

    // P-Wave (Small bump)

    // QRS Complex (The big sharp spike)
    path.lineTo(w * 0.37, mid); // Q (small dip)
    path.lineTo(w * 0.47, mid - h * 0.3); // R (big peak)
    path.lineTo(w * 0.52, mid + h * 0.2); // S (dip below baseline)
    path.lineTo(w * 0.63, mid);

    // T-Wave (Medium bump)

    // Ending Baseline
    path.lineTo(w * 0.9, mid);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
