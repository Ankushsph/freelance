import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'widgets/analytics_chart.dart';
import 'widgets/facebook_content_analytics_sheet.dart';

class FacebookAnalyticsScreen extends StatefulWidget {
  const FacebookAnalyticsScreen({super.key});

  @override
  State<FacebookAnalyticsScreen> createState() => _FacebookAnalyticsScreenState();
}

class _FacebookAnalyticsScreenState extends State<FacebookAnalyticsScreen> {
  String selectedTab = 'Reach';
  bool showCalendar = false;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  bool isLoading = true;
  DateTime currentMonth = DateTime.now();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String contentFilter = 'Posts';
  
  Map<String, dynamic> analyticsData = {};
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);
    
    try {
      final data = await ApiService.getAnalytics(
        platform: 'facebook',
        days: endDate.difference(startDate).inDays,
      );
      
      setState(() {
        analyticsData = data;
        posts = List<Map<String, dynamic>>.from(data['posts'] ?? _getSamplePosts());
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        posts = _getSamplePosts();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSamplePosts() {
    return [
      {
        'id': '1',
        'caption': 'Life lately...',
        'thumbnail': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        'authorName': 'Manushi Chillar',
        'authorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      },
      {
        'id': '2',
        'caption': 'Today at News9 global',
        'thumbnail': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
        'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
        'authorName': 'Kanganaraunt',
        'authorAvatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100',
      },
      {
        'id': '3',
        'caption': 'Across the table',
        'thumbnail': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
        'image': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800',
        'authorName': 'Manushi Chillar',
        'authorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      },
      {
        'id': '4',
        'caption': 'Out of this world',
        'thumbnail': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        'authorName': 'Rhea Kapoor',
        'authorAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      },
      {
        'id': '5',
        'caption': 'Beat the heat',
        'thumbnail': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        'authorName': 'Harshilss',
        'authorAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      },
      {
        'id': '6',
        'caption': 'Sway-ing',
        'thumbnail': 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=200',
        'image': 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
        'authorName': 'Manushi Chillar',
        'authorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      },
    ];
  }

  String get dateRangeText {
    final days = endDate.difference(startDate).inDays;
    if (days == 7) return 'Last 7 Days';
    if (days == 30) return 'Last 30 Days';
    return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}';
  }

  Map<String, dynamic> get currentMetrics {
    switch (selectedTab) {
      case 'Reach':
        return {
          'title': 'New users',
          'current': 420,
          'previous': 340,
          'currentData': [300.0, 350.0, 380.0, 360.0, 340.0, 380.0, 420.0],
          'previousData': [280.0, 300.0, 290.0, 310.0, 320.0, 330.0, 340.0],
        };
      case 'Followers':
        return {
          'title': 'New Followers',
          'current': 40,
          'previous': 140,
          'currentData': [80.0, 90.0, 95.0, 85.0, 90.0, 85.0, 40.0],
          'previousData': [120.0, 125.0, 130.0, 128.0, 135.0, 138.0, 140.0],
        };
      case 'Content interaction':
        return {
          'title': 'New Interactions',
          'current': 120,
          'previous': 342,
          'currentData': [100.0, 110.0, 115.0, 120.0, 118.0, 119.0, 120.0],
          'previousData': [320.0, 325.0, 330.0, 328.0, 335.0, 340.0, 342.0],
        };
      case 'Link clicks':
        return {
          'title': 'New Clicks',
          'current': 4,
          'previous': 340,
          'currentData': [2.0, 3.0, 3.5, 3.0, 3.5, 3.8, 4.0],
          'previousData': [320.0, 325.0, 330.0, 328.0, 335.0, 338.0, 340.0],
        };
      default:
        return {
          'title': 'New users',
          'current': 0,
          'previous': 0,
          'currentData': [],
          'previousData': [],
        };
    }
  }

  double get percentageChange {
    final metrics = currentMetrics;
    final current = metrics['current'] as int;
    final previous = metrics['previous'] as int;
    
    if (previous == 0) return 0;
    return ((current - previous) / previous * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'facebook',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF1877F2),
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTabButtons(),
                  if (showCalendar)
                    _buildCalendar()
                  else ...[
                    _buildMetricCard(),
                    _buildContentSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => showCalendar = !showCalendar);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    dateRangeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    final tabs = ['Reach', 'Followers', 'Content interaction', 'Link clicks'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = tab;
                  showCalendar = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1877F2) : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM').format(currentMonth).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedStartDate = null;
                    selectedEndDate = null;
                    showCalendar = false;
                  });
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (selectedStartDate != null && selectedEndDate != null) {
                    setState(() {
                      startDate = selectedStartDate!;
                      endDate = selectedEndDate!;
                      showCalendar = false;
                    });
                    _loadAnalytics();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex + 2 - firstWeekday;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }
                
                final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                final isSelected = _isDateInRange(date);
                final isStart = selectedStartDate != null && 
                    date.year == selectedStartDate!.year &&
                    date.month == selectedStartDate!.month &&
                    date.day == selectedStartDate!.day;
                final isEnd = selectedEndDate != null &&
                    date.year == selectedEndDate!.year &&
                    date.month == selectedEndDate!.month &&
                    date.day == selectedEndDate!.day;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedStartDate == null || (selectedStartDate != null && selectedEndDate != null)) {
                        selectedStartDate = date;
                        selectedEndDate = null;
                      } else if (date.isBefore(selectedStartDate!)) {
                        selectedEndDate = selectedStartDate;
                        selectedStartDate = date;
                      } else {
                        selectedEndDate = date;
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: (isStart || isEnd) ? Border.all(color: const Color(0xFF1877F2), width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  bool _isDateInRange(DateTime date) {
    if (selectedStartDate == null) return false;
    if (selectedEndDate == null) {
      return date.year == selectedStartDate!.year &&
          date.month == selectedStartDate!.month &&
          date.day == selectedStartDate!.day;
    }
    return date.isAfter(selectedStartDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(selectedEndDate!.add(const Duration(days: 1)));
  }

  Widget _buildMetricCard() {
    final metrics = currentMetrics;
    final change = percentageChange;
    final isPositive = change >= 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metrics['title'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrics['current'].toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4CE6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '16 May - Today',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metrics['previous'].toString(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '8 May - 15 May',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: AnalyticsChart(
              currentData: List<double>.from(metrics['currentData']),
              previousData: List<double>.from(metrics['previousData']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    final contentTypes = ['Posts', 'Photos', 'Videos', 'Stories'];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                initialValue: contentFilter,
                onSelected: (value) {
                  setState(() {
                    contentFilter = value;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        contentFilter,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade700),
                    ],
                  ),
                ),
                itemBuilder: (context) => contentTypes.map((type) {
                  return PopupMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...posts.take(3).map((post) => _buildPostItem(post)),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FacebookContentAnalyticsSheet(post: post),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6B4CE6), width: 3),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post['thumbnail'] ?? 'https://via.placeholder.com/60',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['caption'] ?? 'Life lately...',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                          post['authorAvatar'] ?? 'https://via.placeholder.com/20',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post['authorName'] ?? 'Manushi Chillar',
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
          ],
        ),
      ),
    );
  }
}
