import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trend_model.dart';
import '../../providers/platform_provider.dart';
import '../../services/trend_service.dart';
import 'widgets/trend_tab_bar.dart';
import 'widgets/reels_section.dart';
import 'widgets/audio_section.dart';
import 'widgets/saved_grid.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  late PageController _pageController;
  int _currentTab = 0;
  List<Trend> _popularTrends = [];
  List<Trend> _forYouTrends = [];
  List<Trend> _savedTrends = [];
  bool _isLoading = false;
  String _selectedCategory = 'reels';
  String? _lastLoadedPlatform;

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
          DropdownMenuItem(value: 'posts', child: Text('Posts')),
          DropdownMenuItem(value: 'articles', child: Text('Articles')),
        ];
      case 'X':
        return const [
          DropdownMenuItem(value: 'posts', child: Text('Posts')),
          DropdownMenuItem(value: 'threads', child: Text('Threads')),
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
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_selectedCategory == 'reels')
          ReelsSection(trends: _forYouTrends, onSave: _onSaveTrend)
        else if (_selectedCategory == 'audio')
          AudioSection(trends: _forYouTrends, onSave: _onSaveTrend),
      ]),
    );
  }

  Widget _buildPopularTab() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_selectedCategory == 'reels')
          ReelsSection(trends: _popularTrends, onSave: _onSaveTrend)
        else if (_selectedCategory == 'audio')
          AudioSection(trends: _popularTrends, onSave: _onSaveTrend),
      ]),
    );
  }

  Widget _buildSavedTab() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_selectedCategory == 'reels')
          SavedGrid(trends: _savedTrends, onUnsave: _onUnsaveTrend)
        else if (_selectedCategory == 'audio')
          AudioSection(trends: _savedTrends, onSave: _onSaveTrend),
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