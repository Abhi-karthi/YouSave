import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:english_words/src/word_pair.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'main.dart';
import 'homepage.dart';
import 'select_age.dart';
import 'cprConfirmation.dart';
import 'package:flutter/material.dart';
import 'call911.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// region MARK: Countdown
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

  final ValueNotifier<int> roundNotifier = ValueNotifier(1);
  final ValueNotifier<int> totalBeatsNotifier = ValueNotifier(0);
  final ValueNotifier<int> beatsNotifier = ValueNotifier(0);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> breathsNotifier = ValueNotifier(1);
  final ValueNotifier<String> reasonForStoppingNotifier = ValueNotifier("");
  late String currentAge;

  DateTime now = DateTime.now();

  late String formattedTime = DateFormat('MMM d, yyyy HH:mm').format(now);


  bool counting = true;
  bool isDoneActive = false;
  final GlobalKey<_StopCPRState> childKey = GlobalKey();

  Timer? _timer;

  // region Timer Logic
  @override
  void initState() {
    super.initState();

    WakelockPlus.enable(); // 1. Turn it ON when the CPR Page opens
    var appState = context.read<MyAppState>();
    currentAge = appState.currentAge;

    AudioPlayer.global.setAudioContext(AudioContextConfig(
      respectSilence: false, // This forces it to play even if the phone is on silent!
    ).build());

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
        totalBeatsNotifier.value++;
        beatsNotifier.value++;
        AudioPlayer().play(AssetSource('sounds/tick.mp3'), mode: PlayerMode.lowLatency);
        if (beatsNotifier.value >= 30) {
          beatsNotifier.value = 0;
          roundNotifier.value++;
          _togglePause();
          _showBreathsMenu();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();

    roundNotifier.dispose();
    totalBeatsNotifier.dispose();
    beatsNotifier.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _togglePause() {
    setState(() {
      counting = !counting;
    });
  }

  void _resetCounts() {
    roundNotifier.value = 1;
    totalBeatsNotifier.value = 0;
    beatsNotifier.value = 0;
    // Optional: counting = true; if you want it to auto-resume on reset
  }
  // endregion

  // region Breath callback functions
  void _showBreathsMenu() {
    showDialog(
        context: context,
        barrierDismissible: false, // Prevents closing by tapping the dark background
        barrierColor: Colors.black87,
        builder: (BuildContext context) {
          return RescueBreathsMenu(roundNotifier: roundNotifier, togglePause: _togglePause, openBreathsChecklist: _showBreathsChecklist,);
        }
    );
  }

  void _showBreathsChecklist() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return RescueBreathsChecklist(showRescueBreathsDialogue: _showBreathsDialogue);
        }
    );
  }

  void _showBreathsDialogue() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        breathsNotifier.value++;
        return RescueBreathsDialogue(breathsNotifier: breathsNotifier, firstBreathDialogue: _showFirstBreathDialogue,);
      }
    );
  }

  void _showFirstBreathDialogue() {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (BuildContext context) {
          return FirstBreathDialogue(onComplete: _showSecondBreathStarter,);
        }
    );
  }

  void _showSecondBreathStarter() {
    if (breathsNotifier.value < 3) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (BuildContext context) {
          breathsNotifier.value++;
          return SecondBreathStarter(onComplete: _showFirstBreathDialogue);
        }
      );
    } else {
      _togglePause();
      breathsNotifier.value = 1;
    }
  }
  // endregion

  void _showCPRReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // MUST be true to allow custom heights!
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CPRReport(
          formattedTime: formattedTime,
          rounds: roundNotifier,
          totalCompressions: totalBeatsNotifier,
          reasonForStopping: reasonForStoppingNotifier,
          age: currentAge,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.read<MyAppState>();
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
      appBar: AppBar(title: const Text('CPR Instructions')),
      // 1. REPLACED SingleChildScrollView with a robust ListView
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Center(child: Call911Button(togglePause: _togglePause, isCounting: counting)),

          const SizedBox(height: 20),

          ExcludeSemantics(
            child: SizedBox(
              height: 25,
              child: ValueListenableBuilder<int>(
                valueListenable: totalBeatsNotifier,
                builder: (context, totalBeats, child) {
                  return Text(
                    'Round ${roundNotifier.value} | Total Beats: $totalBeats',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  );
                },
              ),
            ),
          ),

          ExcludeSemantics(
            child: SizedBox(
              height: 90,
              child: ValueListenableBuilder<int>(
                valueListenable: beatsNotifier,
                builder: (context, beats, child) {
                  return Text(
                    '$beats',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 75,
                        fontFeatures: [FontFeature.tabularFigures()]),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PauseButton(
                isCounting: counting,
                onToggle: _togglePause,
              ),
              const SizedBox(width: 20),
              RestartButton(
                reset: _resetCounts,
              ),
            ],
          ),
          const SizedBox(height: 15),

          Center(
            child: RepaintBoundary(
              child: Container(
                  width: 350,
                  height: instructionsHeight,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CPRInstructionText(currAge: currAge)),
            ),
          ),

          Center(
            child: RepaintBoundary(
              child: Container(
                  width: 350,
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: StopCPR(
                    onSelectionChanged: (bool isActive) {
                      setState(() {
                        isDoneActive = isActive;
                      });
                    },
                    reasonForStopping: reasonForStoppingNotifier,
                  )),
            ),
          ),

          Center(
            child: SizedBox(
              width: 383,
              child: ElevatedButton(
                onPressed: isDoneActive ? () {
                  print('Stop CPR NOW');
                } : null,
                onLongPress: isDoneActive ? () {
                  if (counting) _togglePause();
                  _showCPRReport();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDoneActive ? const Color.fromARGB(255, 255, 68, 65) : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(children: [
                  const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '(Press & hold)',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                    )
                  )
                ])
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

// region MARK: CPR Report
class CPRReport extends StatefulWidget {
  final String formattedTime;
  final ValueNotifier<int> rounds;
  final ValueNotifier<int> totalCompressions;
  final ValueNotifier<String> reasonForStopping;
  final String age;

  const CPRReport({super.key, required this.formattedTime, required this.rounds, required this.totalCompressions, required this.reasonForStopping, required this.age});

  @override
  State<CPRReport> createState() => _CPRReportState();
}

class _CPRReportState extends State<CPRReport> {
  @override
  Widget build(BuildContext context) {
    TextStyle reportTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontFamily: 'Courier',
    );

    String time = widget.formattedTime;
    int rounds = widget.rounds.value;
    int totalCompressions = widget.totalCompressions.value;
    String reasonForStopping = widget.reasonForStopping.value;
    String age = widget.age;

    return Container(
      // THE FIX: Force the container to be exactly 60% of the screen height
      height: MediaQuery.of(context).size.height * 0.93,
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(children:[
            SizedBox(width: 10),
            TextButton(
              onPressed: () { Navigator.popUntil(context, (route) => route.isFirst); },
              child: Text(
                "Done",
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 15,
                )
              )
            ),
            Spacer(),
          ]),
          SizedBox(height: 7),
          Text(
            "CPR Report",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 33,
              letterSpacing: -1,
            )
          ),
          SizedBox(height: 40),
          Container(
            width: 330,
            height: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CPR Incident Report",
                  style: reportTextStyle,
                ),
                Text(
                  "--------------------------"
                ),
                Text(
                  "CPR Start Time: $time",
                  style: reportTextStyle,
                ),
                Text(
                  "Age Group of Victim: $age",
                  style: reportTextStyle,
                ),
                Text(
                  "Total Rounds Completed: $rounds",
                  style: reportTextStyle,
                ),
                Text(
                  "Total Compressions: $totalCompressions",
                  style: reportTextStyle,
                ),
                SizedBox(height: 10),
                Text(
                  "Reason for Stopping CPR:",
                  style: reportTextStyle,
                ),
                Text(
                  reasonForStopping,
                  style: reportTextStyle,
                ),
              ]
            )
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 330,
            child: ElevatedButton(
                onPressed: () async {
                  // 1. Copy the text to the clipboard
                  await Clipboard.setData(ClipboardData(text: "CPR Incident Report - CPR Start Time: $time, Age Group of Victim: $age, Total Rounds Completed: $rounds, Total Compressions: $totalCompressions, Reason for stopping CPR: $reasonForStopping"));

                  // 2. Optional: Show a quick little notification at the bottom of the screen!
                  HapticFeedback.lightImpact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 247, 229, 224),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(children: [
                  Spacer(),
                  const Icon(
                    Icons.copy,
                    size: 15,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  const Text(
                      'Copy to Clipboard',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                      )
                  ),
                  Spacer(),
                ])
            ),
          ),
        ],
      ),
    );
  }
}

// endregion

// region MARK: Second Breath Starter
class SecondBreathStarter extends StatelessWidget {
  final VoidCallback onComplete;

  const SecondBreathStarter({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(children: [
        SizedBox(height: 260),
        Text(
          "Allow chest to fall.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )
        ),
        SizedBox(height: 12),
        Text(
          "Ready for Breath 2",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          )
        ),
        SizedBox(height: 15),
        SizedBox(
            width: 383,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 68, 65),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text(
                    "Deliver Breath 2",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
            )
        ),
      ])
    );
  }
}

// endregion

// region MARK: First Breath Dialogue
class FirstBreathDialogue extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstBreathDialogue({super.key, required this.onComplete});

  @override
  State<FirstBreathDialogue> createState() => _FirstBreathDialogueState();
}

class _FirstBreathDialogueState extends State<FirstBreathDialogue> {

  @override
  void initState() {
    super.initState();
    _startBreathTimer();
  }

  void _startBreathTimer() async {

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "GIVE BREATH",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                )
            ),
            const SizedBox(height: 10),
            const Text(
                "1 Second...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                )
            )
          ]
      ),
    );
  }
}
// endregion

// region MARK: Rescue Breaths Dialogue
class RescueBreathsDialogue extends StatelessWidget {
  final ValueNotifier<int> breathsNotifier;
  final VoidCallback firstBreathDialogue;

  const RescueBreathsDialogue({super.key, required this.breathsNotifier, required this.firstBreathDialogue});

  @override
  Widget build(BuildContext context) {
    int currentBreath = breathsNotifier.value-1;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        children: [
          const SizedBox(height: 295),
          Text(
            "Ready for Breath $currentBreath",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            )
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 383,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                firstBreathDialogue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 68, 65),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Text(
                  "Deliver Breath $currentBreath",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            )
          ),
        ]
      ),
    );
  }
}

// endregion

// region MARK: Rescue Breaths Checklist
class RescueBreathsChecklist extends StatefulWidget {
  final VoidCallback showRescueBreathsDialogue;

  const RescueBreathsChecklist({super.key, required this.showRescueBreathsDialogue});

  @override
  State<RescueBreathsChecklist> createState() => _RescueBreathsChecklistState();
}

class _RescueBreathsChecklistState extends State<RescueBreathsChecklist> {
  bool button1 = false;
  bool button2 = false;
  bool button3 = false;
  bool button4 = false;

  void _toggleButton1() {
    setState(() {
      button1 = !button1;
    });
  }

  void _toggleButton2() {
    setState(() {
      button2 = !button2;
    });
  }

  void _toggleButton3() {
    setState(() {
      button3 = !button3;
    });
  }

  void _toggleButton4() {
    setState(() {
      button4 = !button4;
    });
  }

  bool _isAllChecked() {
    return button1 && button2 && button3 && button4;
  }

  @override
  Widget build(BuildContext context) {
    const String button1Text = "Perform Head-Tilt, Chin-Lift Maneuver";
    const String button2Text = "Pinch the casualty's nose cosed";
    const String button3Text = "Form a complete seal over the casualty's mouth";
    const String button4Text = "Give 2 breaths (1 sec each), watch chest rise/fall";

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(height: 75),
              Text(
                "Rescue Breaths",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  letterSpacing: -1,
                )
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: TextButton(
                  onPressed: _toggleButton1,
                  child: Row(
                    children: [
                      Icon(
                        button1 ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 25,
                        color: Colors.red,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          button1Text,
                          style: TextStyle(
                            color: Colors.black,
                          )
                        ),
                      )
                    ]
                  )
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: TextButton(
                    onPressed: _toggleButton2,
                    child: Row(
                        children: [
                          Icon(
                            button2 ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 25,
                            color: Colors.red,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                                button2Text,
                                style: TextStyle(
                                  color: Colors.black,
                                )
                            ),
                          )
                        ]
                    )
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: TextButton(
                    onPressed: _toggleButton3,
                    child: Row(
                        children: [
                          Icon(
                            button3 ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 25,
                            color: Colors.red,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                                button3Text,
                                style: TextStyle(
                                  color: Colors.black,
                                )
                            ),
                          )
                        ]
                    )
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: TextButton(
                    onPressed: _toggleButton4,
                    child: Row(
                        children: [
                          Icon(
                            button4 ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 25,
                            color: Colors.red,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                                button4Text,
                                style: TextStyle(
                                  color: Colors.black,
                                )
                            ),
                          )
                        ]
                    )
                ),
              ),
              SizedBox(height: 345),
              SizedBox(
                  width: 383,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isAllChecked()) {
                        Navigator.of(context)..pop()..pop();
                        widget.showRescueBreathsDialogue();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAllChecked() ? Color.fromARGB(255, 255, 68, 65) : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        "Begin Guided Breaths",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  )
              ),
              SizedBox(height: 15),
              SizedBox(
                  width: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  )
              ),
            ]
          )
        ),
      ),
    );
  }
}
// endregion

// region MARK: Rescue Breaths Menu
class RescueBreathsMenu extends StatelessWidget {
  final ValueNotifier<int> roundNotifier;
  final VoidCallback togglePause;
  final VoidCallback openBreathsChecklist;

  const RescueBreathsMenu({super.key, required this.roundNotifier, required this.togglePause, required this.openBreathsChecklist});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child:
        Column(
            mainAxisSize: MainAxisSize.min, // Hugs the content tightly
            children: [
              Text(
                  "Round ${roundNotifier.value - 1} Complete",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )
              ),
              SizedBox(height: 20),
              Text(
                  "30 compressions given. Now provide 2 breaths.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  )
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 383,
                child: ElevatedButton(
                  onPressed: () {
                    openBreathsChecklist();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 68, 65),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "Start Breaths (Recommended)",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                )
              ),
              SizedBox(height: 18),
              SizedBox(
                width: 383,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(0, 0, 0, 100),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    togglePause();
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "Continue Hands-Only CPR",
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                  )
                )
              )
            ]
        )
    );
  }
}
// endregion

// region MARK: Stop CPR Section
class StopCPR extends StatefulWidget {
  final ValueChanged<bool> onSelectionChanged;
  final ValueNotifier<String> reasonForStopping;
  const StopCPR({super.key, required this.onSelectionChanged, required this.reasonForStopping});

  @override
  State<StopCPR> createState() => _StopCPRState();
}

class _StopCPRState extends State<StopCPR> {
  bool personRegainedConsciousness = false;
  bool EMSArrivedAndTookOver = false;
  bool AEDInUseSwitchedCare = false;
  bool tooExhaustedToContinue = false;

  void off() {
    setState(() {
      personRegainedConsciousness = false;
      EMSArrivedAndTookOver = false;
      AEDInUseSwitchedCare = false;
      tooExhaustedToContinue = false;
    });
  }

  void button1() {
    setState(() {
      bool backOn = false;
      if (!personRegainedConsciousness) {
        backOn = true;
        widget.reasonForStopping.value = "Person regained consciousness";
      }
      off();
      if (backOn) personRegainedConsciousness = true;
    });
    _notifyParent();
  }

  void button2() {
    setState(() {
      bool backOn = false;
      if (!EMSArrivedAndTookOver) {
        backOn = true;
        widget.reasonForStopping.value = "EMS arrived and took over";
      }
      off();
      if (backOn) EMSArrivedAndTookOver = true;
    });
    _notifyParent();
  }

  void button3() {
    setState(() {
      bool backOn = false;
      if (!AEDInUseSwitchedCare) {
        backOn = true;
        widget.reasonForStopping.value = "AED in use / switched care";
      }
      off();
      if (backOn) AEDInUseSwitchedCare = true;
    });
    _notifyParent();
  }

  void button4() {
    setState(() {
      bool backOn = false;
      if (!tooExhaustedToContinue) {
        backOn = true;
        widget.reasonForStopping.value = "Too exhausted to continue";
      }
      off();
      if (backOn) tooExhaustedToContinue = true;
    });
    _notifyParent();
  }

  void _notifyParent() {
    // Uses the radio to send the true/false value up to the main page
    widget.onSelectionChanged(isSelected());
  }

  bool isSelected() {
    return personRegainedConsciousness || EMSArrivedAndTookOver || AEDInUseSwitchedCare || tooExhaustedToContinue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
          "Stop CPR Checklist",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
      ),
      Text(
          "Only one of the options has to be checked.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          )
      ),
      SizedBox(height: 5),
      TextButton(
          onPressed: button1,
          child: Row(children: [
            Icon(
              personRegainedConsciousness ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.red,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              "Person regained consciousness",
              style: TextStyle(fontSize: 16, color: Colors.black),
            )
          ])
      ),
      SizedBox(height: 5),
      TextButton(
          onPressed: button2,
          child: Row(children: [
            Icon(
              EMSArrivedAndTookOver ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.red,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              "EMS arrived and took over",
              style: TextStyle(fontSize: 16, color: Colors.black),
            )
          ])
      ),
      SizedBox(height: 5,),
      TextButton(
          onPressed: button3,
          child: Row(children: [
            Icon(
              AEDInUseSwitchedCare ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.red,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              "AED in use / switched care",
              style: TextStyle(fontSize: 16, color: Colors.black),
            )
          ])
      ),
      SizedBox(height: 5,),
      TextButton(
          onPressed: button4,
          child: Row(children: [
            Icon(
              tooExhaustedToContinue ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.red,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              "Too exhausted to continue",
              style: TextStyle(fontSize: 16, color: Colors.black),
            )
          ])
      ),
    ]);
  }
}
// endregion

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
  final VoidCallback togglePause;
  final bool isCounting;

  const Call911Button({super.key, required this.togglePause, required this.isCounting});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 383,
      child: ElevatedButton(
        onPressed: () {
          print('Call 911 pressed');
          if (isCounting) {
            togglePause();
          }
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
