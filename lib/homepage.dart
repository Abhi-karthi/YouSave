import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'select_age.dart';
import 'mainMenu.dart';

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
                  const SizedBox(width: 15.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(1.0),
                      backgroundColor: const Color.fromARGB(255, 255, 71, 71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainMenuPage()),
                      );
                    },
                    child: const Icon(Icons.info, size: 24.0),
                  ),
                ],
              ),

              const Spacer(flex: 1), // Dynamically pushes the title down

              const Text(
                'YOU SAVE',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                  fontSize: 52.0,
                  letterSpacing: -0.3,
                ),
              ),
              const Text(
                'Every Beat Counts',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(flex: 2), // The flexible spring! Replaces the 170 SizedBox

              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectAgePage()),
                  );
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: Column(
                  children: [
                    AnimatedScale(
                      scale: _isPressed ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: const Color.fromARGB(255, 239, 59, 59),
                            size: MediaQuery.of(context).size.width * 0.7,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,  // Roughly equivalent to 93
                            height: MediaQuery.of(context).size.width * 0.38,
                            child: CustomPaint(painter: ECGLinesPainter()),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'CARDIAC ARREST',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 237, 66, 66),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3), // Pushes the heart up slightly from the bottom border
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
      ..color = Colors.white
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double w = size.width;
    double h = size.height;
    double mid = h / 2;

    path.moveTo(w * 0.1, mid);
    path.lineTo(w * 0.37, mid);
    path.lineTo(w * 0.47, mid - h * 0.3);
    path.lineTo(w * 0.52, mid + h * 0.2);
    path.lineTo(w * 0.63, mid);
    path.lineTo(w * 0.9, mid);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}