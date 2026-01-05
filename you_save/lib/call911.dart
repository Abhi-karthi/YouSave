import 'dart:ui';

import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprChecklist.dart';

class Call911Page extends StatelessWidget {
  const Call911Page({super.key, required this.appState});

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 300),
            Icon(Icons.phone, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text("Calling 911..."),
          ],
        ),
      ),
    );
  }
}
