import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'cprPage.dart';

class CPRChecklist extends StatefulWidget {
  @override
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
      appBar: AppBar(title: const Text('CPR Checklist')),
      // The LayoutBuilder trick ensures Spacers work perfectly on any screen size!
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        appState.currentAge,
                        style: const TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 253, 75, 75),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const FirstBox(),
                      const SizedBox(height: 24),
                      const Text(
                        'Pre-CPR Checklist',
                        style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Checkboxes
                      _buildChecklistItem(0),
                      _buildChecklistItem(1),
                      _buildChecklistItem(2),

                      const Spacer(), // Replaces the giant 210 SizedBox safely!

                      StartCPRButton(checklist: pre_cpr_checklist),

                      const SizedBox(height: 50), // Safe bottom padding
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChecklistItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          pre_cpr_checklist[index] = !pre_cpr_checklist[index];
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10.0),
        child: Row(
          children: [
            Icon(
                pre_cpr_checklist[index] ? Icons.check_box : Icons.check_box_outline_blank,
                color: const Color(0xFFE53935)
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                checklist[index],
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartCPRButton extends StatelessWidget {
  final List<bool> checklist;
  const StartCPRButton({super.key, required this.checklist});

  @override
  Widget build(BuildContext context) {
    bool allChecked = !checklist.contains(false); // Clean trick to check all bools!

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: allChecked ? const Color.fromARGB(255, 255, 70, 67) : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: allChecked ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CPRPage()),
        );
      } : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 96.0, vertical: 12.0),
        child: Text('Begin CPR', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({super.key});

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: const Color.fromARGB(255, 255, 210, 210),
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 18.0, color: Color(0xFFE53935)),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'Ensure someone is calling 911',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: Color(0xFFE53935)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 18.0, color: Color(0xFFE53935)),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'Ensure someone is getting an AED',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: Color(0xFFE53935)),
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