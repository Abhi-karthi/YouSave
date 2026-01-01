import 'dart:ui';

import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              Image.asset(
                'lib/heart_without_bg.png',
                width: 200,
                height: 200,
                // fit: ContentMode.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
