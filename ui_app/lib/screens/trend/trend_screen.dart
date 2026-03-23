import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trend_model.dart';
import '../../providers/platform_provider.dart';
import '../../services/trend_service.dart';
import 'widgets/trend_tab_bar.dart';
import 'widgets/reels_section.dart';
import 'widgets/audio_section.dart';
import 'widgets/saved_grid.dart';
import 'widgets/posts_section.dart';
import 'widgets/hashtags_section.dart';
import 'widgets/videos_section.dart';
import 'widgets/articles_section.dart';
import 'widgets/categories_section.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int _currentTab = 0;
  List<Trend> _popularTrends = [];
  List<Trend> _forYouTrends = [];
  List<Trend> _savedTrends = [];
  bool _isLoading = false;
  String _selectedCategory = 'reels';
  String? _lastLoadedPlatform;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final platformProvider = context.read<PlatformProvider>();
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    if (_lastLoadedPlatform != apiPlatform) {
      _lastLoadedPlatform = apiPlatform;
      _loadTrends(apiPlatform);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTrends(String platform) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final popular = await TrendService.getPopularTrends(
        platform: platform,
        category: _selectedCategory,
      );
      final forYou = await TrendService.getForYouTrends(
        platform: platform,
        userId: '64f8c9b3e4b0f9a2d8c3e1a5',
        category: _selectedCategory,
      );
      final saved = await TrendService.getSavedTrends(
        userId: '64f8c9b3e4b0f9a2d8c3e1a5',
        platform: platform,
      );
      if (mounted) {
        setState(() {
          _popularTrends = popular;
          _forYouTrends = forYou;
          _savedTrends = saved;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(int index) {
    setState(() => _currentTab = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    final platformProvider = context.read<PlatformProvider>();
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    _loadTrends(apiPlatform);
  }

  List<DropdownMenuItem<String>> _categoryItems(String platformId) {
    switch (platformId) {
      case 'LN':
        return const [
          DropdownMenuItem(value: 'videos', child: Text('Videos')),
          DropdownMenuItem(value: 'posts', child: Text('Posts')),
        ];
      case 'X':
        return const [
          DropdownMenuItem(value: 'tweets', child: Text('Tweets')),
        ];
      case 'FB':
        return const [
          DropdownMenuItem(value: 'posts', child: Text('Post')),
        ];
      default:
        return const [
          DropdownMenuItem(value: 'reels', child: Text('Reels')),
          DropdownMenuItem(value: 'audio', child: Text('Audio')),
          DropdownMenuItem(value: 'posts', child: Text('Posts')),
          DropdownMenuItem(value: 'videos', child: Text('Videos')),
        ];
    }
  }
  
  List<Map<String, dynamic>> _getTrendingHashtags(String platformId) {
    if (platformId == 'LN') {
      return [
        {'name': 'innovation', 'followers': 38800000},
        {'name': 'management', 'followers': 36000000},
        {'name': 'humanresources', 'followers': 33200000},
      ];
    }
    return [
      {'name': 'Top model'},
      {'name': 'makeup'},
      {'name': 'photographer'},
      {'name': 'fashion'},
      {'name': 'fashionblogger'},
    ];
  }
  
  List<Map<String, dynamic>> _getCategories() {
    return [
      {'name': 'Healthcare'},
      {'name': 'Marketing and Sales'},
      {'name': 'Marketing & Advertising'},
      {'name': 'Events'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlatformProvider>(
      builder: (context, platformProvider, _) {
        final platformId = platformProvider.selectedPlatform;
        final apiPlatform = platformProvider.getPlatformApiName(platformId);
        final platformName = platformProvider.getPlatformName(platformId);

        // Compute valid category for the new platform upfront
        final items = _categoryItems(platformId);
        final validValues = items.map((e) => e.value!).toList();
        final resolvedCategory = validValues.contains(_selectedCategory)
            ? _selectedCategory
            : validValues.first;

        // When platform changes: reset category AND reload in one callback
        // to avoid race condition (loading with the wrong/old category).
        if (_lastLoadedPlatform != apiPlatform) {
          _lastLoadedPlatform = apiPlatform;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            // Reset category first (synchronously inside setState), then load
            setState(() => _selectedCategory = resolvedCategory);
            _loadTrends(apiPlatform);
          });
        } else if (resolvedCategory != _selectedCategory) {
          // Platform didn't change but category became invalid (shouldn't happen,
          // but guard against it anyway)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedCategory = resolvedCategory);
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              platformName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: Column(
            children: [
              TrendTabBar(currentTab: _currentTab, onTabChanged: _onTabChanged),
              // Category dropdown (hidden for Twitter since it only has Tweets)
              if (platformId != 'X')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: resolvedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: items,
                      onChanged: (value) {
                        if (value != null) _onCategoryChanged(value);
                      },
                    ),
                  ),
                )
              else
                // Show "Tweets" header for Twitter
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tweets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentTab = i),
                        children: [
                          _buildForYouTab(),
                          _buildPopularTab(),
                          _buildSavedTab(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForYouTab() {
    final platformProvider = context.read<PlatformProvider>();
    final platformId = platformProvider.selectedPlatform;
    final apiPlatform = platformProvider.getPlatformApiName(platformId);
    
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // LinkedIn: Videos section
        if (platformId == 'LN' && _selectedCategory == 'videos')
          VideosSection(trends: _forYouTrends, onSave: _onSaveTrend),
        
        // LinkedIn: Articles section (always show after videos)
        if (platformId == 'LN' && _selectedCategory == 'videos')
          ArticlesSection(trends: _forYouTrends.take(3).toList(), onSave: _onSaveTrend),
        
        // Instagram: Reels
        if (platformId == 'IG' && _selectedCategory == 'reels')
          ReelsSection(trends: _forYouTrends, onSave: _onSaveTrend),
        
        // Audio section
        if (_selectedCategory == 'audio')
          AudioSection(trends: _forYouTrends, onSave: _onSaveTrend),
        
        // Posts/Tweets section
        if (_selectedCategory == 'posts' || _selectedCategory == 'tweets')
          PostsSection(
            trends: _forYouTrends,
            onSave: _onSaveTrend,
            platform: apiPlatform,
          ),
        
        // Audio section for Facebook/Twitter (not LinkedIn)
        if ((platformId == 'FB' || platformId == 'X') && _selectedCategory != 'audio')
          AudioSection(trends: _forYouTrends.take(2).toList(), onSave: _onSaveTrend),
        
        // Hashtags section (not for Instagram reels)
        if ((platformId == 'FB' || platformId == 'X' || platformId == 'LN') && 
            _selectedCategory != 'reels')
          HashtagsSection(
            hashtags: _getTrendingHashtags(platformId),
            showFollowers: platformId == 'LN',
          ),
        
        // Categories section (LinkedIn only)
        if (platformId == 'LN')
          CategoriesSection(categories: _getCategories()),
      ]),
    );
  }

  Widget _buildPopularTab() {
    final platformProvider = context.read<PlatformProvider>();
    final platformId = platformProvider.selectedPlatform;
    final apiPlatform = platformProvider.getPlatformApiName(platformId);
    
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // LinkedIn: Videos section
        if (platformId == 'LN' && _selectedCategory == 'videos')
          VideosSection(trends: _popularTrends, onSave: _onSaveTrend),
        
        // LinkedIn: Articles section
        if (platformId == 'LN' && _selectedCategory == 'videos')
          ArticlesSection(trends: _popularTrends.take(3).toList(), onSave: _onSaveTrend),
        
        // LinkedIn: Posts with sort icon
        if (platformId == 'LN' && _selectedCategory == 'posts')
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort, color: Colors.black),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              PostsSection(
                trends: _popularTrends,
                onSave: _onSaveTrend,
                platform: apiPlatform,
              ),
            ],
          ),
        
        // Instagram: Reels
        if (platformId == 'IG' && _selectedCategory == 'reels')
          ReelsSection(trends: _popularTrends, onSave: _onSaveTrend),
        
        // Audio section
        if (_selectedCategory == 'audio')
          AudioSection(trends: _popularTrends, onSave: _onSaveTrend),
        
        // Posts/Tweets section (not LinkedIn)
        if ((platformId == 'FB' || platformId == 'X') && 
            (_selectedCategory == 'posts' || _selectedCategory == 'tweets'))
          PostsSection(
            trends: _popularTrends,
            onSave: _onSaveTrend,
            platform: apiPlatform,
          ),
        
        // Audio section for Facebook/Twitter
        if ((platformId == 'FB' || platformId == 'X') && _selectedCategory != 'audio')
          AudioSection(trends: _popularTrends.take(2).toList(), onSave: _onSaveTrend),
        
        // Hashtags section
        if ((platformId == 'FB' || platformId == 'X' || platformId == 'LN') && 
            _selectedCategory != 'reels')
          HashtagsSection(
            hashtags: _getTrendingHashtags(platformId),
            showFollowers: platformId == 'LN',
          ),
        
        // Categories section (LinkedIn only)
        if (platformId == 'LN')
          CategoriesSection(categories: _getCategories()),
      ]),
    );
  }

  Widget _buildSavedTab() {
    final platformProvider = context.read<PlatformProvider>();
    final platformId = platformProvider.selectedPlatform;
    final apiPlatform = platformProvider.getPlatformApiName(platformId);
    
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // LinkedIn: Videos grid
        if (platformId == 'LN' && _selectedCategory == 'videos') ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Videos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          if (_savedTrends.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _savedTrends.length,
                itemBuilder: (context, index) {
                  final trend = _savedTrends[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      trend.content.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ArticlesSection(trends: _savedTrends.take(1).toList(), onSave: _onSaveTrend),
        ],
        
        // Instagram: Reels grid
        if (platformId == 'IG' && _selectedCategory == 'reels')
          SavedGrid(trends: _savedTrends, onUnsave: _onUnsaveTrend),
        
        // Audio section
        if (_selectedCategory == 'audio')
          AudioSection(trends: _savedTrends, onSave: _onSaveTrend),
        
        // Posts/Tweets grid
        if ((_selectedCategory == 'posts' || _selectedCategory == 'tweets') && 
            platformId != 'LN') ...[
          if (_savedTrends.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: platformId == 'X' ? 4 : 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _savedTrends.length,
                itemBuilder: (context, index) {
                  final trend = _savedTrends[index];
                  return ClipRRect(
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
                  );
                },
              ),
            ),
          if (_savedTrends.isNotEmpty)
            PostsSection(
              trends: [_savedTrends.first],
              onSave: _onSaveTrend,
              platform: apiPlatform,
            ),
        ],
        
        // Audio section for Facebook/Twitter
        if ((platformId == 'FB' || platformId == 'X') && _selectedCategory != 'audio')
          AudioSection(trends: _savedTrends.take(1).toList(), onSave: _onSaveTrend),
        
        // Hashtags section
        if ((platformId == 'FB' || platformId == 'X' || platformId == 'LN') && 
            _selectedCategory != 'reels')
          HashtagsSection(
            hashtags: _getTrendingHashtags(platformId),
            showFollowers: platformId == 'LN',
          ),
        
        // Categories section (LinkedIn only)
        if (platformId == 'LN')
          CategoriesSection(categories: _getCategories()),
      ]),
    );
  }

  Future<void> _onSaveTrend(Trend trend) async {
    final platformProvider = context.read<PlatformProvider>();
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    final success = await TrendService.saveTrend(
      userId: '64f8c9b3e4b0f9a2d8c3e1a5',
      trendId: trend.id,
      platform: apiPlatform,
      category: _selectedCategory,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Trend saved!')));
      _loadTrends(apiPlatform);
    }
  }

  Future<void> _onUnsaveTrend(Trend trend) async {
    final platformProvider = context.read<PlatformProvider>();
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    _loadTrends(apiPlatform);
  }
}