import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'suggestion_card.dart';

class EmptyState extends StatelessWidget {
  final Function(String)? onSuggestionTap;

  const EmptyState({this.onSuggestionTap, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 50),

          Image.asset(
            'assets/images/ai/bot.png',
            height: 140,
          ),

          const SizedBox(height: 24),

          const Text(
            "Hello!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xff6A5AE0),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "How can I help you today?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 36),

          SuggestionGrid(
            onSuggestionTap: onSuggestionTap,
          ),
        ],
      ),
    );
  }
}