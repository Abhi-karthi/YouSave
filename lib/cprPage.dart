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
import 'dart:async';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onCountdownComplete;

  const CountdownOverlay({super.key, required this.onCountdownComplete});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int count = 2; // Starts at 2 seconds

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    // Loop to handle the countdown
    while (count > 0) {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          count--;
        });
      }
    }

    // Optional: wait a split second on "0" or "GO!" before closing
    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      widget.onCountdownComplete(); // Tell the parent we are done!
    }
  }

  @override
  Widget build(BuildContext context) {
    // A transparent dialog lets the gray barrier show through behind the text
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Text(
          count > 0 ? '$count' : 'GO!',
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CPRPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CPRPageState createState() => _CPRPageState();
}

class _CPRPageState extends State<CPRPage> {

  int round = 1;
  int totalBeats = 0;
  int beats = 0;
  bool counting = true;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Wait for the screen to build, THEN show the countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCountdownDialog();
    });
  }

  void _showCountdownDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents user from tapping outside to dismiss it early
      builder: (BuildContext context) {
        return CountdownOverlay(
          onCountdownComplete: () {
            Navigator.of(context).pop(); // 1. Close the dialog
            _startTimer();               // 2. Start your main CPR timer
          },
        );
      },
    );
  }

  void _startTimer() {
    // Your exact timer logic from before goes here!
    _timer = Timer.periodic(Duration(milliseconds: 600), (timer) {
      if (counting) {
        setState(() {
          totalBeats++;
          beats++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ALWAYS cancel timers when leaving the page to prevent memory leaks
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      counting = !counting;
    });
  }

  void _resetCounts() {
    setState(() {
      round = 1;
      totalBeats = 0;
      beats = 0;
      // Optional: counting = true; if you want it to auto-resume on reset
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
                PauseButton(
                  isCounting: counting,
                  onToggle: _togglePause,
                ),
                SizedBox(width: 20),
                RestartButton(
                  rounds: round,
                  beats: beats,
                  totalBeats: totalBeats,
                ),
              ],
            ),
            SizedBox(height: 30,),
            Text(
              'Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 75)
            )
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

class PauseButton extends StatelessWidget {
  final bool isCounting; // The information
  final VoidCallback onToggle; // The remote control

  const PauseButton({
    super.key,
    required this.isCounting,
    required this.onToggle
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onToggle, // When pressed, use the remote control!
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 242, 232, 232),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(
            isCounting ? Icons.pause : Icons.play_arrow,
            size: 22,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          SizedBox(width: 10),
          Text(
            isCounting ? 'Pause' : 'Resume',
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 20),
            Text(
              "(If anyone else isn't available)",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
