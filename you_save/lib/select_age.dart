import 'dart:ui';

import 'package:english_words/src/word_pair.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'cprConfirmation.dart';

class SelectAgePage extends StatelessWidget {
  const SelectAgePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(title: Text('Select Age:')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                appState.setCurrentAge('Adult');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CPRConfirmationPage(),
                  ),
                );

                print(appState.currentAge);
              },
              child: Image.asset(
                'lib/assets/Adult-age-selection.png',
                width: 150,
                height: 150,
                // fit: ContentMode.contain,
              ),
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                appState.setCurrentAge('Child');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CPRConfirmationPage(),
                  ),
                );
                print('Child');
              },
              child: Image.asset(
                'lib/assets/Child-age-selection.png',
                width: 150,
                height: 150,
                // fit: ContentMode.contain,
              ),
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                appState.setCurrentAge('Infant');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CPRConfirmationPage(),
                  ),
                );
                print('Infant');
              },
              child: Image.asset(
                'lib/assets/Infant-age-selection.png',
                width: 150,
                height: 150,
                // fit: ContentMode.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
