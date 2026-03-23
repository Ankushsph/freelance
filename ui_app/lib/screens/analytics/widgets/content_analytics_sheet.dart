import 'package:flutter/material.dart';

class ContentAnalyticsSheet extends StatefulWidget {
  final Map<String, dynamic> post;

  const ContentAnalyticsSheet({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<ContentAnalyticsSheet> createState() => _ContentAnalyticsSheetState();
}

class _ContentAnalyticsSheetState extends State<ContentAnalyticsSheet> {
  String selectedPeriod = 'Last 7 Days';

  @override
  Widget build(BuildContext context) {
    final periods = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'Custom'];
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Instagram',
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Content Analytics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Date range
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PopupMenuButton<String>(
                    initialValue: selectedPeriod,
                    onSelected: (value) {
                      setState(() {
                        selectedPeriod = value;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedPeriod,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => periods.map((period) {
                      return PopupMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Author info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.post['authorAvatar'] ?? 'https://via.placeholder.com/40',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post['authorName'] ?? 'Manushi Chillar',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.post['caption'] ?? 'Not to miss the "chill" in chillar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Post image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.post['image'] ?? 'https://via.placeholder.com/400',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Content score
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.6,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DA1F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '60%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DA1F2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Overview section
                _buildMetricSection(
                  'Overview',
                  [
                    {'label': 'Reach', 'value': '945', 'change': '+20%', 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Impressions', 'value': '957', 'change': null, 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Interaction', 'value': '23', 'change': null, 'color': const Color(0xFF1DA1F2)},
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Plays and watch time section
                _buildMetricSection(
                  'Plays and watch time',
                  [
                    {'label': 'Plays', 'value': '1,212', 'change': '+20%', 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Avg. watch time', 'value': '5s', 'change': null, 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Watch time', 'value': '1h 26 m', 'change': null, 'color': const Color(0xFF1DA1F2)},
                  ],
                ),
                
                const SizedBox(height): 20),
                
                // Interactions section
                _buildMetricSection(
                  'Interactions',
                  [
                    {'label': 'Likes', 'value': '856', 'change': null, 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Comments', 'value': '45', 'change': null, 'color': const Color(0xFF1DA1F2)},
                    {'label': 'Shares', 'value': '12', 'change': null, 'color': const Color(0xFF1DA1F2)},
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricSection(String title, List<Map<String, dynamic>> metrics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: metrics.map((metric) {
                return Column(
                  children: [
                    Text(
                      metric['label'],
                      style: TextStyle(
                        fontSize: 13,
                        color: metric['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      metric['value'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (metric['change'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        metric['change'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
