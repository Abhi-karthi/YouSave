import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'select_age.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        backgroundColor: Colors.grey.shade50, // Matches the slightly off-white background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 100,
          leading: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.blue),
            label: const Text(
              "Back",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
            ),
          ),
          title: const Text(
            "How this app works",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                      "How this app works",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Matched the muted red
                        letterSpacing: -0.5,
                      )
                  ),
                  const SizedBox(height: 24),

                  _buildInstructionItem(
                    "1) Press “Cardiac Arrest”.",
                    "This takes you to the CPR tutorial.",
                  ),
                  _buildInstructionItem(
                    "2) Select Patient Age.",
                    "Choose Adult, Child, or Infant. This tailors the instructions.",
                  ),
                  _buildInstructionItem(
                    "3) Call 911 / Start CPR.",
                    "You get quick-access buttons to call 911 or proceed to the Pre-CPR Checklist.",
                  ),
                  _buildInstructionItem(
                    "4) Complete Pre-CPR Checklist.",
                    "Confirm the scene, patient condition, and hand placement before you begin.",
                  ),
                  _buildInstructionItem(
                    "5) Follow the 30:2 Pace.",
                    "The app provides a ~100 BPM metronome for 30 compressions, then pauses.",
                  ),
                  _buildInstructionItem(
                    "6) Give 2 Breaths (Optional).",
                    "After 30 beats, a menu appears. You can follow the guided breaths checklist or skip to continue hands-only.",
                  ),
                  _buildInstructionItem(
                    "7) Stop CPR & Report.",
                    "When help arrives or you must stop, select a reason from the checklist to enable the 'Done' button. A medical report is generated.",
                  ),

                  const SizedBox(height: 50),
                ]
            )
        )
    );
  }

  // A helper function to build the numbered list cleanly
  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4, // Adds nice spacing between lines of a paragraph
            ),
          ),
        ],
      ),
    );
  }
}