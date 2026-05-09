import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'cprConfirmation.dart';

class SelectAgePage extends StatelessWidget {
  const SelectAgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age Selection')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const IntrinsicHeight(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 24),
                      Text(
                        "Select Age:",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 61, 61),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(height: 40),
                      AdultElevatedButton(),
                      SizedBox(height: 24),
                      ChildElevatedButton(),
                      SizedBox(height: 24),
                      InfantElevatedButton(),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
          MaterialPageRoute(builder: (context) => const CPRConfirmationPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Adult', style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
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
          MaterialPageRoute(builder: (context) => const CPRConfirmationPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Child', style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
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
          MaterialPageRoute(builder: (context) => const CPRConfirmationPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 61, 61),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: const Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Infant', style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('< 1 year', style: TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }
}