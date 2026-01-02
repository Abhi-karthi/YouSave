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
            AdultElevatedButton(),
            SizedBox(height: 60),
            ChildElevatedButton(),
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

class AdultElevatedButton extends StatelessWidget {
  const AdultElevatedButton({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ElevatedButton(
      onPressed: () {
        appState.setCurrentAge('Adult');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CPRConfirmationPage()),
        );
        print('Adult');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Adult',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Puberty & Above', style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}

class ChildElevatedButton extends StatelessWidget {
  const ChildElevatedButton({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ElevatedButton(
      onPressed: () {
        appState.setCurrentAge('Child');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CPRConfirmationPage()),
        );
        print('Child');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Child',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Below Puberty', style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}

class InfantElevatedButton extends StatelessWidget {
  const InfantElevatedButton({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ElevatedButton(
      onPressed: () {
        appState.setCurrentAge('Infant');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CPRConfirmationPage()),
        );
        print('Infant');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Infant',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('< 1 year', style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}
