import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konnect/providers/platform_provider.dart';
import '../../services/api_service.dart';

/// ================= DATA MODELS =================

class PostItem {
  final String id;
  final String? message;
  final String? caption;
  final String createdTime;
  final String? mediaType;
  final Map<String, dynamic>? insights;

  PostItem({
    required this.id,
    this.message,
    this.caption,
    required this.createdTime,
    this.mediaType,
    this.insights,
  });

  String get displayText => caption ?? message ?? 'No caption';
  
  int get impressions => insights?['impressions'] ?? 0;
  int get reach => insights?['reach'] ?? 0;
  int get engagement => insights?['engagement'] ?? 0;
  int get likes => insights?['likes'] ?? 0;
  int get comments => insights?['comments'] ?? 0;
  int get shares => insights?['shares'] ?? 0;
  int get saved => insights?['saved'] ?? 0;
}

/// ================= MAIN SCREEN =================

class AnaScreen extends StatefulWidget {
  const AnaScreen({super.key});

  @override
  State<AnaScreen> createState() => _AnaScreenState();
}

class _AnaScreenState extends State<AnaScreen> {
  int selectedDays = 7;
  bool isLoading = true;
  String? error;
  
  Map<String, dynamic>? analyticsData;
  List<PostItem> posts = [];

  final metrics = ['Reach', 'Impressions', 'Engagement'];
  String selectedMetric = 'Reach';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  String get selectedPlatform {
    return Provider.of<PlatformProvider>(context, listen: false).selectedPlatform;
  }

  PlatformConfig get config => getPlatformConfig(selectedPlatform);

  Future<void> _loadAnalytics() async {

    if (selectedPlatform == 'X' || selectedPlatform == 'LN') {
      setState(() {
        isLoading = false;
        error = null;
        analyticsData = null;
        posts = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final platform = getPlatformConfig(selectedPlatform);
      final data = await ApiService.getAnalytics(
        platform: platform.apiName,
        days: selectedDays,
      );

      setState(() {
        analyticsData = data;
        posts = _parsePosts(data['posts'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<PostItem> _parsePosts(List<dynamic> postsData) {
    return postsData.map((p) => PostItem(
      id: p['id'] ?? '',
      message: p['message'],
      caption: p['caption'],
      createdTime: p['created_time'] ?? p['timestamp'] ?? '',
      mediaType: p['media_type'],
      insights: p['insights'],
    )).toList();
  }

  Map<String, int> get overviewData {
    final overview = analyticsData?['overview'] ?? {};
    return {
      'reach': overview['reach'] ?? 0,
      'impressions': overview['impressions'] ?? 0,
      'engagement': overview['engagement'] ?? 0,
      'followers': overview['followers'] ?? 0,
    };
  }

  bool get hasPermissionsError => analyticsData?['permissionsError'] ?? false;

  List<Map<String, dynamic>> get historyData {
    return List<Map<String, dynamic>>.from(analyticsData?['history'] ?? []);
  }

  PlatformConfig get currentConfig => getPlatformConfig(selectedPlatform);

  int get currentMetricValue {
    switch (selectedMetric) {
      case 'Reach':
        return overviewData['reach'] ?? 0;
      case 'Impressions':
        return overviewData['impressions'] ?? 0;
      case 'Engagement':
        return overviewData['engagement'] ?? 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Analytics', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadAnalytics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrentPlatformIndicator(),
            const SizedBox(height: 16),
            _dateRangeSelector(),
            const SizedBox(height: 16),
            if (isLoading)
              _buildLoadingWidget()
            else if (error != null)
              _buildErrorWidget()
            else if (selectedPlatform == 'X' || selectedPlatform == 'LN')
              _buildUnsupportedPlatformWidget()
            else
              ...[
                if (hasPermissionsError) _permissionsWarningCard(),
                if (hasPermissionsError) const SizedBox(height: 16),
                _overviewCard(),
                const SizedBox(height: 16),
                if (posts.isNotEmpty) _postsCard(),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUnsupportedPlatformWidget() {
    final platformName = selectedPlatform == 'X' ? 'X (Twitter)' : 'LinkedIn';
    final platformColor = selectedPlatform == 'X' ? const Color(0xFF000000) : const Color(0xFF0A66C2);
    
    return _card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedPlatform == 'X' ? Icons.flutter_dash : Icons.business,
            size: 64,
            color: platformColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '$platformName Analytics Coming Soon',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Analytics for $platformName are currently under development. Please use Instagram or Facebook analytics for now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.read<PlatformProvider>().setSelectedPlatform('IG');
                  _loadAnalytics();
                },
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Go to Instagram'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4405F),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<PlatformProvider>().setSelectedPlatform('FB');
                  _loadAnalytics();
                },
                icon: const Icon(Icons.facebook, size: 18),
                label: const Text('Go to Facebook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permissionsWarningCard() {
    return _card(
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Analytics Permissions Required',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'To view analytics data, your Facebook app needs additional permissions that require Meta approval. Analytics are currently only available for app administrators during development.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return _card(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAnalytics,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlatformIndicator() {
    final config = currentConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Image.asset(
            config.iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${config.name} Analytics',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: config.color,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            'Change on Home',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Last 7 Days'),
          selected: selectedDays == 7,
          selectedColor: config.color,
          labelStyle: TextStyle(
            color: selectedDays == 7 ? Colors.white : Colors.black,
          ),
          onSelected: (_) {
            setState(() => selectedDays = 7);
            _loadAnalytics();
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Last 30 Days'),
          selected: selectedDays == 30,
          selectedColor: config.color,
          labelStyle: TextStyle(
            color: selectedDays == 30 ? Colors.white : Colors.black,
          ),
          onSelected: (_) {
            setState(() => selectedDays = 30);
            _loadAnalytics();
          },
        ),
      ],
    );
  }

  Widget _overviewCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _overviewHeader(),
          const SizedBox(height: 16),
          _metricChips(),
          const SizedBox(height: 24),
          _statsGrid(),
          const SizedBox(height: 24),
          if (historyData.isNotEmpty) _chart(),
        ],
      ),
    );
  }

  Widget _overviewHeader() {
    final connected = analyticsData?['connected'] ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (!connected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Not Connected',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _metricChips() {
    return Wrap(
      spacing: 8,
      children: metrics.map((m) {
        final selected = selectedMetric == m;
        return ChoiceChip(
          label: Text(m),
          selected: selected,
          selectedColor: config.color,
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
          onSelected: (_) => setState(() => selectedMetric = m),
        );
      }).toList(),
    );
  }

  Widget _statsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Impressions', overviewData['impressions'] ?? 0, Icons.visibility),
        _statCard('Reach', overviewData['reach'] ?? 0, Icons.people_outline),
        _statCard('Engagement', overviewData['engagement'] ?? 0, Icons.favorite_outline),
        _statCard('Followers', overviewData['followers'] ?? 0, Icons.person_add),
      ],
    );
  }

  Widget _statCard(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: config.color, size: 24),
          const SizedBox(height: 8),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: config.color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  Widget _chart() {

    final List<double> chartData = historyData.map<double>((h) {
      switch (selectedMetric) {
        case 'Reach':
          return ((h['reach'] ?? 0) as num).toDouble();
        case 'Impressions':
          return ((h['impressions'] ?? 0) as num).toDouble();
        case 'Engagement':
          return ((h['engagement'] ?? 0) as num).toDouble();
        default:
          return 0.0;
      }
    }).toList();

    if (chartData.isEmpty || chartData.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$selectedMetric Trend',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 10),
          child: CustomPaint(
            painter: LinePainter(
              data: chartData,
              color: config.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _postsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                '${posts.length} posts',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...posts.take(10).map((post) => _postListTile(post)),
        ],
      ),
    );
  }

  Widget _postListTile(PostItem post) {

    IconData typeIcon;
    switch (post.mediaType?.toUpperCase()) {
      case 'REELS':
        typeIcon = Icons.video_library;
        break;
      case 'VIDEO':
        typeIcon = Icons.videocam;
        break;
      case 'CAROUSEL_ALBUM':
        typeIcon = Icons.collections;
        break;
      case 'STORY':
        typeIcon = Icons.auto_stories;
        break;
      default:
        typeIcon = Icons.image;
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: config.color.withOpacity(0.1),
        child: Icon(typeIcon, color: config.color),
      ),
      title: Text(
        post.displayText.length > 50 
          ? '${post.displayText.substring(0, 50)}...' 
          : post.displayText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.mediaType?.replaceAll('_', ' ') ?? 'Post',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          Text(
            '${post.reach} reach • ${post.engagement} engagement',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _showPostDetails(post),
    );
  }

  void _showPostDetails(PostItem post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  post.displayText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text(
                  'Post Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: config.color,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _detailStat('Reach', post.reach),
                    _detailStat('Impressions', post.impressions),
                    _detailStat('Engagement', post.engagement),
                    _detailStat('Likes', post.likes),
                    _detailStat('Comments', post.comments),
                    _detailStat('Shares', post.shares),
                    _detailStat('Saved', post.saved),
                  ],
                ),
                const SizedBox(height: 16),
                if (post.mediaType?.toUpperCase() == 'REELS' || post.mediaType?.toUpperCase() == 'STORY')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${post.mediaType} metrics are limited. Some metrics like impressions may not be available.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Posted: ${post.createdTime.substring(0, 10)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailStat(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatNumber(value),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

/// ================= LINE CHART PAINTER =================

class LinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double safeMax = maxValue == 0 ? 1 : maxValue;


    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = data.length > 1 ? size.width / (data.length - 1) : size.width;

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - (data[i] / safeMax * size.height * 0.8) - (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);


    final dotPaint = Paint()..color = color;
    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - (data[i] / safeMax * size.height * 0.8) - (size.height * 0.1);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }


    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}