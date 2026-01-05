import 'dart:ui';

import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprChecklist.dart';
import 'call911.dart';

class CPRConfirmationPage extends StatelessWidget {
  const CPRConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: Text('CPR Confirmation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appState.currentAge,
              style: TextStyle(
                fontSize: 42.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 253, 75, 75),
              ),
            ),
            SizedBox(height: 190),
            Call911(appState: appState),
            SizedBox(height: 30),
            StartCPR(appState: appState),
            SizedBox(height: 285),
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
    return ElevatedButton(
      onPressed: () {
        print('Start CPR pressed');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CPRChecklist()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 93.0, vertical: 20.0),
        child: Text(
          'Start CPR',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
    return ElevatedButton(
      onPressed: () {
        print('Call 911 pressed');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Call911Page(appState: MyAppState()),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        fixedSize: const Size(350, 115),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text(
              'Call 911',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'If you are alone, call now. Otherwise, tell someone else to.',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}
