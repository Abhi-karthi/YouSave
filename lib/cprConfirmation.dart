import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'cprChecklist.dart';
import 'call911.dart';

class CPRConfirmationPage extends StatelessWidget {
  const CPRConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('CPR Confirmation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1), // Flexible padding!
            Text(
              appState.currentAge,
              style: const TextStyle(
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 253, 75, 75),
              ),
            ),
            const Spacer(flex: 5),
            Call911(appState: appState),
            const SizedBox(height: 30), // Keeps the two buttons locked near each other
            StartCPR(appState: appState),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

class StartCPR extends StatelessWidget {
  const StartCPR({super.key, required this.appState});

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.84,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CPRChecklist()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 61, 61),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'Start CPR',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class Call911 extends StatelessWidget {
  const Call911({super.key, required this.appState});

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.84,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Call911Page(appState: appState),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 61, 61),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(14.0),
          child: Column(
            children: [
              Text('Call 911', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('If you are alone, call now. Otherwise, tell someone else to.', style: TextStyle(fontSize: 12.0)),
            ],
          ),
        ),
      ),
    );
  }
}