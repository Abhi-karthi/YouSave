import 'dart:ui';

import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprConfirmation.dart';

class CPRChecklist extends StatelessWidget {
  const CPRChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var checklist = [];
    return Scaffold(
      appBar: AppBar(title: Text('CPR Checklist')),
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
            SizedBox(height: 30),
            FirstBox(),
          ],
        ),
      ),
    );
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 177, 177),
      padding: EdgeInsets.all(20.0), // Add some padding inside the container
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.phone, size: 11.0),
              SizedBox(width: 5.0),
              Text(
                'Ensure someone is calling 911',
                style: TextStyle(fontSize: 10.0),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite, size: 11.0),
              SizedBox(width: 5.0),
              Text(
                'Ensure someone is getting an AED',
                style: TextStyle(fontSize: 10.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
