import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:english_words/src/word_pair.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprConfirmation.dart';
import 'package:flutter/material.dart';
import 'call911.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';

// region Countdown
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
// endregion

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

  // region Timer Logic
  @override
  void initState() {
    super.initState();

    WakelockPlus.enable(); // 1. Turn it ON when the CPR Page opens

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
    WakelockPlus.disable();
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
  // endregion

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currAge = appState.currentAge;
    double instructionsHeight;
    if (currAge == "Infant") {
      instructionsHeight = 360;
    } else if (currAge == "Child") {
      instructionsHeight = 300;
    } else {
      instructionsHeight = 320;
    }

    return Scaffold(
      appBar: AppBar(title: Text('CPR Instructions')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Call911Button(),  // 911 Button
            SizedBox(height: 20),
            Text(  // Round and beats small text
              'Round $round | Total Beats: $totalBeats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(  // Big beats text
              '$beats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 75),
            ),
            Row(  // Pause and resume buttons
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PauseButton(
                  isCounting: counting,
                  onToggle: _togglePause,
                ),
                SizedBox(width: 20),
                RestartButton(
                  reset: _resetCounts,
                ),
              ],
            ),
            SizedBox(height: 30,),
            Container(  // CPR instructions container
              // Styling:
              width: 350,
              height: instructionsHeight,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 10),

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // A soft drop shadow
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4), // Moves the shadow down slightly
                  ),
                ],
              ),

              // Values
              child: CPRInstructionText(currAge: currAge)
            ),
            SizedBox(height: 20),
      Container(  // CPR instructions container
        // Styling:
          width: 350,
          height: 200,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(vertical: 40),

          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // A soft drop shadow
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4), // Moves the shadow down slightly
              ),
            ],
          ),

          // Values
          child: StopCPR()
      ),
      ],
    ),
    ),
    )
    );
  }
}

class StopCPR extends StatefulWidget {
  const StopCPR({super.key});

  @override
  State<StopCPR> createState() => _StopCPRState();
}

class _StopCPRState extends State<StopCPR> {
  bool personRegainedConsciousness = false;
  bool EMSArrivedAndTookOver = false;
  bool AEDInUseSwitchedCare = false;
  bool tooExhaustedToContinue = false;

  void off() {
    personRegainedConsciousness = false;
    EMSArrivedAndTookOver = false;
    AEDInUseSwitchedCare = false;
    tooExhaustedToContinue = false;
  }

  void button1() {
    off();
    if (personRegainedConsciousness) return;
    personRegainedConsciousness = true;
  }

  void button2() {
    off();
    if (EMSArrivedAndTookOver) return;
    EMSArrivedAndTookOver = true;
  }

  void button3() {
    off();
    if (AEDInUseSwitchedCare) return;
    AEDInUseSwitchedCare = true;
  }

  void button4() {
    off();
    if (tooExhaustedToContinue) return;
    tooExhaustedToContinue = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [

    ]);
  }
}

// region MARK: CPR Instruction Text
class CPRInstructionText extends StatelessWidget {
  final String currAge;
  const CPRInstructionText({
    super.key,
    required this.currAge,
  });

  @override
  Widget build(BuildContext context) {
    String instructions_1 = "";
    String instructions_2 = "";
    String instructions_3 = "";

    if (currAge == "Adult") {
      instructions_1 = "Tap & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions_2 = "Hands only: heel of hand center of chest, other hand on top; arms straight. Push hard & fast (100-120/min), depth at least 2 in (5 cm). Allow full recoil.";
      instructions_3 = "Minimize interruptions. Use an AED immediately when it arrives.";
    }
    else if (currAge == "Child") {
      instructions_1 = "Tap & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions_2 = "Use 1 or 2 hands on the center of the chest. Push hard & fast (100-120/min), depth about 2 in (5 cm). Allow full recoil.";
      instructions_3 = "Minimize interruptions. Use an AED immediately (use child pads if available).";
    }
    else if (currAge == "Infant") {
      instructions_1 = "Tap bottom of foot & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions_2 = "Use 2 fingers in the center of the chest, just below the nipple line. Push hard & fast (100-120/min), depth about 1.5 in (4 cm). Allow full recoil.";
      instructions_3 = "Minimize interruptions. Use an AED immediately (use infant pads if available).";
    }
    return Column(
      children: [
        Text(
          'How to perform CPR - $currAge',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Row(
          children:[
            Icon(
              Icons.verified,
              color: Colors.red, // Matches your image
              size: 20.0,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                instructions_1,
              ),
            )
          ]
        ),
        SizedBox(height: 20),
        Row(
            children:[
              Icon(
                Icons.verified,
                color: Colors.red, // Matches your image
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  instructions_2,
                ),
              )
            ]
        ),
        SizedBox(height: 20),
        Row(
            children:[
              Icon(
                Icons.verified,
                color: Colors.red, // Matches your image
                size: 20.0,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  instructions_3,
                ),
              )
            ]
        ),
      ],
    );
  }
}
// endregion

// region MARK: Restart and Pause Buttons
class RestartButton extends StatelessWidget {
  final VoidCallback reset;
  const RestartButton({
    super.key,
    required this.reset,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: reset,
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
// endregion

// region MARK: Call 911 Button
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
// endregion
