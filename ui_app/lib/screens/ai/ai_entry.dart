import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_intro_screen.dart';
import 'ai_chat_screen.dart';

class AIEntry extends StatefulWidget {
  const AIEntry({super.key});

  @override
  State<AIEntry> createState() => _AIEntryState();
}

class _AIEntryState extends State<AIEntry> {
  bool? seen;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('ai_bot') ?? false;

    setState(() {
      seen = hasSeen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (seen == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return seen! ? const AIChatScreen() : const AIIntroScreen();
  }
}