import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/k_button.dart';

class AIIntroScreen extends StatelessWidget {
  const AIIntroScreen({super.key});


  Future<void> _markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_bot', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              /// Title
              const Text(
                "Your AI Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5968EA),
                ),
              ),

              const SizedBox(height: 15),

              /// Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "Our AI-powered chatbot feature brings personalized content suggestions, trend updates, and even assists in content creation.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              /// Illustration
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/ai/ai_intro.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: KButton(
                    text: "Continue",
                    onTap: () async {
                      await _markIntroSeen();

                      Navigator.pushReplacementNamed(
                        context,
                        '/ai_chat',
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}