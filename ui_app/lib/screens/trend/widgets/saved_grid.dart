import 'package:flutter/material.dart';
import '../../../models/trend_model.dart';

class SavedGrid extends StatelessWidget {
  final List<Trend> trends;
  final Function(Trend) onUnsave;

  const SavedGrid({
    Key? key,
    required this.trends,
    required this.onUnsave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No saved reels yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: trends.length,
        itemBuilder: (context, index) {
          final trend = trends[index];
          return _buildGridItem(context, trend);
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Trend trend) {
    return GestureDetector(
      onLongPress: () => onUnsave(trend),
      child: Stack(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              trend.content.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
          // Play icon overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
