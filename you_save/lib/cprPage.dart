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
    var round = 1;
    var totalBeats = 0;
    var beats = 0;
    var counting = true;

    return Scaffold(
      appBar: AppBar(title: Text('CPR Instructions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Call911Button(),
            SizedBox(height: 20),
            Text(
              'Round $round | Total Beats: $totalBeats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '$beats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 75),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PauseButton(counting: counting),
                SizedBox(width: 20),
                RestartButton(
                  rounds: round,
                  beats: beats,
                  totalBeats: totalBeats,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RestartButton extends StatefulWidget {
  final int rounds;
  final int beats;
  final int totalBeats;
  const RestartButton({
    super.key,
    required this.rounds,
    required this.beats,
    required this.totalBeats,
  });

  @override
  State<RestartButton> createState() => _RestartButtonState();
}

class _RestartButtonState extends State<RestartButton> {
  late int localRounds;
  late int localBeats;
  late int localTotalBeats;

  @override
  void initState() {
    super.initState();
    localRounds = widget.rounds;
    localBeats = widget.beats;
    localTotalBeats = widget.totalBeats;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          localRounds = 1;
          localBeats = 0;
          localTotalBeats = 0;
        });
        print(
          "Reset to Round: $localRounds, Beats: $localBeats, Total Beats: $localTotalBeats",
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 242, 232, 232),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.restart_alt,
            size: 18,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          SizedBox(width: 4),
          Text(
            "Reset",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class PauseButton extends StatefulWidget {
  final bool counting; // This is a "snapshot" and can NEVER change
  const PauseButton({super.key, required this.counting});

  @override
  State<PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<PauseButton> {
  // 1. Create a local variable that CAN change
  late bool localIsCounting;

  @override
  void initState() {
    super.initState();
    // 2. Initialize it ONCE using the value passed from the constructor
    localIsCounting = widget.counting;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 3. Use setState to flip the local variable and RE-DRAW the button
        setState(() {
          localIsCounting = !localIsCounting;
        });
        print("The button now says: $localIsCounting");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 242, 232, 232),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // 4. Use the local variable to decide what text to show
      child: Row(
        children: [
          Icon(
            localIsCounting ? Icons.pause : Icons.play_arrow,
            size: 22,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          SizedBox(width: 10),
          Text(
            localIsCounting ? 'Pause' : 'Resume',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class Call911Button extends StatelessWidget {
  const Call911Button({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 383,
      child: ElevatedButton(
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
          backgroundColor: Color.fromARGB(255, 255, 68, 65),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.phone, size: 30, color: Colors.white),
            SizedBox(width: 20),
            Text(
              'Call 911',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
