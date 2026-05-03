import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class Call911Page extends StatelessWidget {
  const Call911Page({super.key, required this.appState});

  final MyAppState appState;

  // Function to trigger the native phone dialer safely
  Future<void> _launchCaller() async {
    // Using a mock number for safe testing on your iPhone
    final Uri telUri = Uri(scheme: 'tel', path: '555-555-5555');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        debugPrint('Could not launch dialer');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Call"),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                "Confirm Emergency Call",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tap the button below to dial emergency services. Once the call starts, put your phone on speakerphone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // THE BUTTON THINGY: Large, obvious button to trigger the call
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  onLongPress: _launchCaller,
                  icon: Row(children:[
                    const Icon(Icons.phone, size: 30, color: Colors.white),
                    SizedBox(width: 15),
                  ]),
                  label: Column(children: [
                    SizedBox(height: 15),
                    const Text(
                      "DIAL EMERGENCY",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Press & Hold",
                      style: TextStyle(fontSize: 12),
                    )
                  ]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel and Return to Instructions",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
