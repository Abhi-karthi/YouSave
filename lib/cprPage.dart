import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'main.dart';
import 'package:flutter/services.dart';
import 'call911.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:intl/intl.dart';

// region MARK: Countdown
class CountdownOverlay extends StatefulWidget {
  final VoidCallback onCountdownComplete;

  const CountdownOverlay({super.key, required this.onCountdownComplete});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int count = 2;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    while (count > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          count--;
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onCountdownComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Text(
          count > 0 ? '$count' : 'GO!',
          style: const TextStyle(
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
  final AudioPlayer _tickPlayer = AudioPlayer();

  DateTime now = DateTime.now();

  late String formattedTime = DateFormat('MMM d, yyyy HH:mm').format(now);


  bool counting = true;
  bool isDoneActive = false;

  Timer? _timer;

  // region Timer Logic
  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
    var appState = context.read<MyAppState>();
    currentAge = appState.currentAge;

    AudioPlayer.global.setAudioContext(AudioContextConfig(
      respectSilence: false,
    ).build());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCountdownDialog();
    });
  }

  void _showCountdownDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CountdownOverlay(
          onCountdownComplete: () {
            Navigator.of(context).pop();
            _startTimer();
          },
        );
      },
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (counting) {
        totalBeatsNotifier.value++;
        beatsNotifier.value++;

        // ---> THE AUDIO BUG FIX <---
        // Forcibly clear the previous sound handle so the hardware never skips!
        _tickPlayer.stop().then((_) {
          _tickPlayer.play(AssetSource('sounds/tick.mp3'), mode: PlayerMode.lowLatency);
        });

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
    _tickPlayer.dispose();

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
  }
  // endregion

  // region Breath callback functions
  void _showBreathsMenu() {
    showDialog(
        context: context,
        barrierDismissible: false,
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
    breathsNotifier.value++;
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (BuildContext context) {
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
        isScrollControlled: true,
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
    // double instructionsHeight;
    // if (currAge == "Infant") {
    //   instructionsHeight = (360/2796) * MediaQuery.of(context).size.height;
    // } else if (currAge == "Child") {
    //   // instructionsHeight = (300/2796) * MediaQuery.of(context).size.height;
    //   instructionsHeight = MediaQuery.of(context).size.height * 0.3;
    // } else {
    //   instructionsHeight = (320/2796) * MediaQuery.of(context).size.height;
    // }

    return Scaffold(
      appBar: AppBar(title: const Text('CPR Instructions')),
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Center(child: Call911Button(togglePause: _togglePause, isCounting: counting, appState: appState)),

          Spacer(flex: 2),

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

          Spacer(flex: 2),

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

          Spacer(flex: 2),

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
          Spacer(flex: 1),

          Center(
            child: RepaintBoundary(
              child: Container(
                  width: 350,
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

          Spacer(flex: 2),

          Center(
            child: RepaintBoundary(
              child: Container(
                  width: 350,
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

          Spacer(flex: 2),

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
                  child: const Column(children: [
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
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
    const TextStyle reportTextStyle = TextStyle(
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
      height: MediaQuery.of(context).size.height * 0.93,
      width: double.infinity,
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
            const SizedBox(width: 10),
            TextButton(
                onPressed: () { Navigator.popUntil(context, (route) => route.isFirst); },
                child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 15,
                    )
                )
            ),
            const Spacer(),
          ]),
          const SizedBox(height: 7),
          const Text(
              "CPR Report",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 33,
                letterSpacing: -1,
              )
          ),
          const SizedBox(height: 40),
          Container(
              width: 330,
              padding: const EdgeInsets.all(15), // Let the container hug the text naturally
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Hugs content perfectly
                  children: [
                    const Text("CPR Incident Report", style: reportTextStyle),
                    const Text("--------------------------", style: reportTextStyle),
                    Text("CPR Start Time: $time", style: reportTextStyle),
                    Text("Age Group of Victim: $age", style: reportTextStyle),
                    Text("Total Rounds Completed: $rounds", style: reportTextStyle),
                    Text("Total Compressions: $totalCompressions", style: reportTextStyle),
                    const SizedBox(height: 10),
                    const Text("Reason for Stopping CPR:", style: reportTextStyle),
                    Text(reasonForStopping, style: reportTextStyle),
                  ]
              )
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 330,
            child: ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: "CPR Incident Report - CPR Start Time: $time, Age Group of Victim: $age, Total Rounds Completed: $rounds, Total Compressions: $totalCompressions, Reason for stopping CPR: $reasonForStopping"));
                  HapticFeedback.lightImpact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 247, 229, 224),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(children: [
                  Spacer(),
                  Icon(Icons.copy, size: 15, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Copy to Clipboard', style: TextStyle(fontSize: 11, color: Colors.red)),
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

// ---> THE UI DIALOG FIXES <---
// Removed all giant SizedBoxes and used mainAxisSize: MainAxisSize.min to instantly center!

// region MARK: Second Breath Starter
class SecondBreathStarter extends StatelessWidget {
  final VoidCallback onComplete;

  const SecondBreathStarter({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
            mainAxisSize: MainAxisSize.min, // Instantly centers the content!
            children: [
              const Text(
                  "Allow chest to fall.",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              const Text(
                  "Ready for Breath 2",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Deliver Breath 2",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
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
    return const Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "GIVE BREATH",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                )
            ),
            SizedBox(height: 10),
            Text("1 Second...", style: TextStyle(color: Colors.white, fontSize: 24))
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
          mainAxisSize: MainAxisSize.min, // Hugs content perfectly
          children: [
            Text(
                "Ready for Breath $currentBreath",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)
            ),
            const SizedBox(height: 20),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "Deliver Breath $currentBreath",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
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

  void _toggleButton1() => setState(() => button1 = !button1);
  void _toggleButton2() => setState(() => button2 = !button2);
  void _toggleButton3() => setState(() => button3 = !button3);
  void _toggleButton4() => setState(() => button4 = !button4);

  bool _isAllChecked() {
    return button1 && button2 && button3 && button4;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
            width: 450,
            height: MediaQuery.of(context).size.height * 1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView( // Allows scrolling on tiny screens!
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                    mainAxisSize: MainAxisSize.min, // Eliminates massive empty space
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.1),
                      const Text(
                          "Rescue Breaths",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 40, letterSpacing: -1)
                      ),
                      const SizedBox(height: 30),
                      _buildChecklistRow(button1, "Perform Head-Tilt, Chin-Lift Maneuver", _toggleButton1),
                      const SizedBox(height: 10),
                      _buildChecklistRow(button2, "Pinch the casualty's nose closed", _toggleButton2),
                      const SizedBox(height: 10),
                      _buildChecklistRow(button3, "Form a complete seal over the casualty's mouth", _toggleButton3),
                      const SizedBox(height: 10),
                      _buildChecklistRow(button4, "Give 2 breaths (1 sec each), watch chest rise/fall", _toggleButton4),

                      Spacer(),

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
                                backgroundColor: _isAllChecked() ? const Color.fromARGB(255, 255, 68, 65) : Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Begin Guided Breaths",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                              )
                          )
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                          width: 70,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white70,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Back", style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
                          )
                      ),
                      const SizedBox(height: 30),
                    ]
                ),
              ),
            )
        ),
      ),
    );
  }

  Widget _buildChecklistRow(bool isChecked, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextButton(
          onPressed: onTap,
          child: Row(
              children: [
                Icon(isChecked ? Icons.check_box : Icons.check_box_outline_blank, size: 25, color: Colors.red),
                const SizedBox(width: 15),
                Expanded(child: Text(text, style: const TextStyle(color: Colors.black))),
              ]
          )
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Round ${roundNotifier.value - 1} Complete",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 20),
              const Text(
                  "30 compressions given. Now provide 2 breaths.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white)
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: 383,
                  child: ElevatedButton(
                      onPressed: () {
                        openBreathsChecklist();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 68, 65),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Start Breaths (Recommended)",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                  )
              ),
              const SizedBox(height: 18),
              SizedBox(
                  width: 383,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(100, 0, 0, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        togglePause();
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("Continue Hands-Only CPR", style: TextStyle(color: Colors.white)),
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
    widget.onSelectionChanged(isSelected());
  }

  bool isSelected() {
    return personRegainedConsciousness || EMSArrivedAndTookOver || AEDInUseSwitchedCare || tooExhaustedToContinue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
          "Stop CPR Checklist",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
      ),
      const Text(
          "Only one of the options has to be checked.",
          style: TextStyle(color: Colors.grey, fontSize: 10)
      ),
      const SizedBox(height: 5),
      TextButton(
          onPressed: button1,
          child: Row(children: [
            Icon(personRegainedConsciousness ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.red, size: 25),
            const SizedBox(width: 10),
            Expanded(child: const Text("Person regained consciousness", style: TextStyle(fontSize: 16, color: Colors.black)))
          ])
      ),
      const SizedBox(height: 5),
      TextButton(
          onPressed: button2,
          child: Row(children: [
            Icon(EMSArrivedAndTookOver ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.red, size: 25),
            const SizedBox(width: 10),
            Expanded(child: const Text("EMS arrived and took over", style: TextStyle(fontSize: 16, color: Colors.black)))
          ])
      ),
      const SizedBox(height: 5,),
      TextButton(
          onPressed: button3,
          child: Row(children: [
            Icon(AEDInUseSwitchedCare ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.red, size: 25),
            const SizedBox(width: 10),
            Expanded(child: const Text("AED in use / switched care", style: TextStyle(fontSize: 16, color: Colors.black)))
          ])
      ),
      const SizedBox(height: 5,),
      TextButton(
          onPressed: button4,
          child: Row(children: [
            Icon(tooExhaustedToContinue ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.red, size: 25),
            const SizedBox(width: 10),
            Expanded(child: const Text("Too exhausted to continue", style: TextStyle(fontSize: 16, color: Colors.black)))
          ])
      ),
    ]);
  }
}
// endregion

// region MARK: CPR Instruction Text
class CPRInstructionText extends StatelessWidget {
  final String currAge;
  const CPRInstructionText({super.key, required this.currAge});

  @override
  Widget build(BuildContext context) {
    String instructions1 = "";
    String instructions2 = "";
    String instructions3 = "";

    if (currAge == "Adult") {
      instructions1 = "Tap & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions2 = "Hands only: heel of hand center of chest, other hand on top; arms straight. Push hard & fast (100-120/min), depth at least 2 in (5 cm). Allow full recoil.";
      instructions3 = "Minimize interruptions. Use an AED immediately when it arrives.";
    }
    else if (currAge == "Child") {
      instructions1 = "Tap & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions2 = "Use 1 or 2 hands on the center of the chest. Push hard & fast (100-120/min), depth about 2 in (5 cm). Allow full recoil.";
      instructions3 = "Minimize interruptions. Use an AED immediately (use child pads if available).";
    }
    else if (currAge == "Infant") {
      instructions1 = "Tap bottom of foot & shout. If unresponsive and not breathing normally, SEND someone to call 911 and bring an AED.";
      instructions2 = "Use 2 fingers in the center of the chest, just below the nipple line. Push hard & fast (100-120/min), depth about 1.5 in (4 cm). Allow full recoil.";
      instructions3 = "Minimize interruptions. Use an AED immediately (use infant pads if available).";
    }
    return Column(
      children: [
        Text(
          'How to perform CPR - $currAge',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(children:[const Icon(Icons.verified, color: Colors.red, size: 20.0), const SizedBox(width: 10), Expanded(child: Text(instructions1))]),
        const SizedBox(height: 20),
        Row(children:[const Icon(Icons.verified, color: Colors.red, size: 20), const SizedBox(width: 10), Expanded(child: Text(instructions2))]),
        const SizedBox(height: 20),
        Row(children:[const Icon(Icons.verified, color: Colors.red, size: 20.0), const SizedBox(width: 10), Expanded(child: Text(instructions3))]),
      ],
    );
  }
}
// endregion

// region MARK: Restart and Pause Buttons
class RestartButton extends StatelessWidget {
  final VoidCallback reset;
  const RestartButton({super.key, required this.reset});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: reset,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 242, 232, 232),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.restart_alt, size: 18, color: Color.fromARGB(255, 0, 0, 0)),
          SizedBox(width: 4),
          Text("Reset", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
    );
  }
}

class PauseButton extends StatelessWidget {
  final bool isCounting;
  final VoidCallback onToggle;

  const PauseButton({super.key, required this.isCounting, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onToggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 242, 232, 232),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(isCounting ? Icons.pause : Icons.play_arrow, size: 22, color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 10),
          Text(isCounting ? 'Pause' : 'Resume', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
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
  final MyAppState appState;

  const Call911Button({super.key, required this.togglePause, required this.isCounting, required this.appState});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.84,
      child: ElevatedButton(
        onPressed: () {
          print('Call 911 pressed');
          if (isCounting) {
            togglePause();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Call911Page(appState: appState),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 68, 65),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Expanded(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.phone, size: 30, color: Colors.white),
              Spacer(),
              Text('Call 911', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              Spacer(),
              Text("(If anyone else isn't available)", style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
// endregion