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
import 'cprPage.dart';

class CPRChecklist extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CPRChecklistState createState() => _CPRChecklistState();
}

class _CPRChecklistState extends State<CPRChecklist> {
  var checklist = [];
  var pre_cpr_checklist = [false, false, false];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.currentAge == 'Adult') {
      checklist = [
        'Confirm it is Cardiac Arrest (Tap & Shout, Check Breathing, Check Pulse)',
        'Depth of compression is 2 inches (5 cm)',
        'Heel of one hand on center of chest, other hand on top',
      ];
    } else if (appState.currentAge == 'Child') {
      checklist = [
        'Confirm it is Cardiac Arrest (Tap & Shout, Check Breathing, Check Pulse)',
        'Depth of compression is about 2 inches (5 cm)',
        'Use one or two hands on center of chest',
      ];
    } else if (appState.currentAge == 'Infant') {
      checklist = [
        'Confirm it is Cardiac Arrest (Tap & Shout, Check Breathing, Check Pulse)',
        'Depth of compression is about 1.5 inches (4 cm)',
        'Use two fingers in center of chest just below nipple line',
      ];
    }

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
            SizedBox(height: 24),
            FirstBox(),
            SizedBox(height: 24),
            Text(
              'Pre-CPR Checklist',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  pre_cpr_checklist[0] = !pre_cpr_checklist[0];
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    FirstCheckBox(isChecked: pre_cpr_checklist[0]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        checklist[0],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  pre_cpr_checklist[1] = !pre_cpr_checklist[1];
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    FirstCheckBox(isChecked: pre_cpr_checklist[1]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        checklist[1],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  pre_cpr_checklist[2] = !pre_cpr_checklist[2];
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10.0,
                ),
                child: Row(
                  children: [
                    FirstCheckBox(isChecked: pre_cpr_checklist[2]),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        checklist[2],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 210),
            StartCPRButton(checklist: pre_cpr_checklist),
            SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class StartCPRButton extends StatefulWidget {
  final List<bool> checklist;
  const StartCPRButton({super.key, required this.checklist});

  @override
  State<StartCPRButton> createState() => _StartCPRButtonState();
}

class _StartCPRButtonState extends State<StartCPRButton> {
  @override
  Widget build(BuildContext context) {
    bool allChecked = true;
    for (int i = 0; i < 3; i++) {
      if (!widget.checklist[i]) {
        allChecked = false;
      }
    }
    if (allChecked) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 255, 70, 67),
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CPRPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 96.0, vertical: 12.0),
          child: Text(
            'Begin CPR',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 96.0, vertical: 12.0),
        child: Text(
          'Begin CPR',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class FirstCheckBox extends StatefulWidget {
  final bool isChecked;
  const FirstCheckBox({super.key, required this.isChecked});

  @override
  State<FirstCheckBox> createState() => _FirstCheckBoxState();
}

class _FirstCheckBoxState extends State<FirstCheckBox> {
  @override
  Widget build(BuildContext context) {
    bool all = true;
    for (int i = 0; i < 3; i++) {
      if (!widget.isChecked) {
        all = false;
      }
    }
    if (widget.isChecked) {
      return Icon(Icons.check_box, color: Color(0xFFE53935));
    }
    return Icon(Icons.check_box_outline_blank, color: Color(0xFFE53935));
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({super.key});

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      // This is the background color of the box
      color: const Color.fromARGB(255, 255, 210, 210),
      // Elevation adds the shadow automatically
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.2),
      // This is what rounds the corners of the PhysicalModel itself
      borderRadius: BorderRadius.circular(25),
      // This forces the children (the Rows/Text) to be clipped to the rounded shape
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: 911 Instruction
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 18.0, color: Color(0xFFE53935)),
                const SizedBox(width: 12.0),
                const Text(
                  'Ensure someone is calling 911',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10), // Spacing between the two rows
            // Row 2: AED Instruction
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  size: 18.0,
                  color: Color(0xFFE53935),
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Ensure someone is getting an AED',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
