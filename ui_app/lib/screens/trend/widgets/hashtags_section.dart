import 'package:flutter/material.dart';

class HashtagsSection extends StatelessWidget {
  final List<Map<String, dynamic>> hashtags;
  final bool showFollowers;

  const HashtagsSection({
    Key? key,
    required this.hashtags,
    this.showFollowers = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hashtags',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hashtags.map((tag) {
              final tagName = tag['name'] ?? tag.toString();
              final followers = tag['followers'];
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DA1F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  showFollowers && followers != null
                      ? '${tagName.startsWith('#') ? tagName : '#$tagName'} (${_formatFollowers(followers)})'
                      : tagName.startsWith('#') ? tagName : '#$tagName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)} million followers';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K followers';
    }
    return '$followers followers';
  }
}
