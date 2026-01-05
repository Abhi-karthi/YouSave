import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprConfirmation.dart';
import 'package:flutter/material.dart';
import 'call911.dart';

class CPRPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CPRPageState createState() => _CPRPageState();
}

class _CPRPageState extends State<CPRPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(title: Text('CPR Instructions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Call911Button(),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CPRChecklist()),
            //     );
            //   },
            //   child: Text('Start CPR Checklist'),
            // ),
          ],
        ),
      ),
    );
  }
}

class Call911Button extends StatelessWidget {
  const Call911Button({super.key});

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
        backgroundColor: Color(0xFFE53935),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        children: [
          Icon(Icons.phone, size: 30, color: Colors.white),
          SizedBox(width: 20),
          Text('Call 911', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
