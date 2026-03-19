import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';

class PostDetailSheet extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PostDetailSheet({
    super.key,
    required this.post,
    required this.onDelete,
    required this.onEdit,
  });

  String _dateLabel(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final day = days[d.weekday - 1];
    final hour = d.hour;
    final min = d.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'p.m.' : 'a.m.';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$day,${d.day} @ $h:$min$period';
  }

  @override
  Widget build(BuildContext context) {
    final scheduledAt = post.scheduledTime ?? post.createdAt;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.platforms.isNotEmpty
                          ? _platformLabel(post.platforms.first)
                          : 'Post',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: EdgeInsets.fromLTRB(
                      16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
                  child: Column(
                    children: [
                      // ── Blue card with image + date ──────────
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: post.mediaUrls.isNotEmpty
                                  ? Image.network(
                                      post.mediaUrls.first,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                            const SizedBox(height: 12),
                            // date pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _dateLabel(scheduledAt),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Delete + Edit buttons ────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: Colors.black26),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Delete',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onEdit,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: Colors.black26),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Edit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.image_outlined, size: 48, color: Colors.white),
    );
  }

  String _platformLabel(String p) {
    switch (p.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'linkedin':
        return 'LinkedIn';
      case 'twitter':
      case 'x':
        return 'X (Twitter)';
      default:
        return p;
    }
  }
}
