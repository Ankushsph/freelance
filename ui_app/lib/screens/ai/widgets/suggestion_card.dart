import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuggestionGrid extends StatelessWidget {
  final Function(String)? onSuggestionTap;

  const SuggestionGrid({this.onSuggestionTap, super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      {"text": "What to post?", "icon": Icons.lightbulb_outline},
      {"text": "When to post?", "icon": Icons.access_time},
      {"text": "Write a tweet about global warming", "icon": Icons.edit},
      {"text": "How do you say 'how are you' in korean?", "icon": Icons.translate},
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SuggestionCard(
                text: suggestions[0]["text"] as String,
                icon: suggestions[0]["icon"] as IconData,
                onTap: onSuggestionTap != null
                    ? () => onSuggestionTap!(suggestions[0]["text"] as String)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SuggestionCard(
                text: suggestions[1]["text"] as String,
                icon: suggestions[1]["icon"] as IconData,
                onTap: onSuggestionTap != null
                    ? () => onSuggestionTap!(suggestions[1]["text"] as String)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SuggestionCard(
                text: suggestions[2]["text"] as String,
                icon: suggestions[2]["icon"] as IconData,
                onTap: onSuggestionTap != null
                    ? () => onSuggestionTap!(suggestions[2]["text"] as String)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SuggestionCard(
                text: suggestions[3]["text"] as String,
                icon: suggestions[3]["icon"] as IconData,
                onTap: onSuggestionTap != null
                    ? () => onSuggestionTap!(suggestions[3]["text"] as String)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const SuggestionCard({
    required this.text,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
          color: onTap != null ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 5),
            Icon(icon, size: 22),
          ],
        ),
      ),
    );
  }
}