import 'package:flutter/material.dart';
import '../../../models/trend_model.dart';

class PostsSection extends StatelessWidget {
  final List<Trend> trends;
  final Function(Trend) onSave;
  final String platform;

  const PostsSection({
    Key? key,
    required this.trends,
    required this.onSave,
    required this.platform,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No posts found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trends.length,
      itemBuilder: (context, index) {
        final trend = trends[index];
        return _buildPostCard(context, trend);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, Trend trend) {
    final bool isTwitter = platform == 'twitter';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Profile + Name + Bookmark
          Row(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(isTwitter ? 25 : 8),
                child: Image.network(
                  trend.creator.avatar,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(isTwitter ? 25 : 8),
                      ),
                      child: const Icon(Icons.person),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Name and handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend.creator.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    if (trend.description != null && trend.description!.isNotEmpty)
                      Text(
                        trend.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Bookmark
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.black),
                onPressed: () => onSave(trend),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          // Post image (if exists)
          if (trend.content.thumbnail.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                trend.content.thumbnail,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
          
          // Engagement stats
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isTwitter ? Icons.thumb_up_outlined : Icons.favorite_border,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatNumber(trend.engagement.likes),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatNumber(trend.engagement.comments),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.remove_red_eye_outlined,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatNumber(trend.engagement.views),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
