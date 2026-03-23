import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:konnect/providers/platform_provider.dart';
import '../providers/subscription_provider.dart';

import '../widgets/bottom_nav_bar.dart';
import '../models/social_profile.dart';
import '../models/social_account.dart';
import '../models/post.dart';
import '../services/mock_social_service.dart';
import '../services/api_service.dart';

import './boost/boost_sheet.dart';

const double kFabSize = 56;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedIndex = -1;


  bool _navVisible = true;

  final List<String?> routes = [
    '/schedule',
    '/trend',
    null,
    '/analytics',
    '/ai_bot',
  ];

  List<SocialAccount> accounts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    
    // Load subscription status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscription();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPostNotifications();
    });
  }

  
  Future<void> _checkPostNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationJson = prefs.getString('post_notification');
    
    if (notificationJson != null) {
      try {
        final notification = jsonDecode(notificationJson);
        final timestamp = DateTime.parse(notification['timestamp']);
        

        if (DateTime.now().difference(timestamp).inSeconds < 30) {
          if (!mounted) return;
          
          final isSuccess = notification['type'] == 'success';
          final isPending = notification['pending'] == true;
          

          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!mounted) return;
          
          _showNotificationBanner(
            message: notification['message'],
            isSuccess: isSuccess,
          );
          

          if (isPending) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _checkPostNotifications();
              }
            });
          } else {

            await prefs.remove('post_notification');
          }
        } else {

          await prefs.remove('post_notification');
        }
      } catch (e) {
        print('Error parsing notification: $e');
        await prefs.remove('post_notification');
      }
    }
  }

  void _showNotificationBanner({
    required String message,
    required bool isSuccess,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 60, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }

  void openBoostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BoostSheet(),
    );
  }

  
  Future<void> _loadAccounts() async {
    final instagramProfile = await MockSocialService.instagram();
    final twitterProfile = MockSocialService.twitter();
    final linkedinProfile = MockSocialService.linkedin();
    final facebookProfile = await MockSocialService.facebook();

    setState(() {
      accounts = [

        SocialAccount(
          name: "Instagram",
          logo: "assets/images/social/ig.png",
          profile: instagramProfile ?? _emptyInstagram(),
        ),

        SocialAccount(
          name: "X",
          logo: "assets/images/social/x.png",
          profile: twitterProfile,
        ),

        SocialAccount(
          name: "LinkedIn",
          logo: "assets/images/social/linkedin.png",
          profile: linkedinProfile,
        ),

        SocialAccount(
          name: "Facebook",
          logo: "assets/images/social/fb.png",
          profile: facebookProfile ?? _emptyFacebook(),
        ),
      ];

      loading = false;
    });
  }

  SocialProfile _emptyInstagram() => SocialProfile(
    name: "Instagram",
    username: "",
    bio: "",
    profileImage: "assets/images/social/ig.png",
    location: "",
    stats: {},
    connected: false,
  );
  SocialProfile _emptyFacebook() => SocialProfile(
    name: "Facebook",
    username: "",
    bio: "",
    profileImage: "assets/images/social/fb.png",
    location: "",
    stats: {},
    connected: false,
  );

  
  void _onItemTap(int index) async {
    // Check subscription status from SubscriptionProvider
    final subscriptionProvider = context.read<SubscriptionProvider>();
    
    // Load subscription if not already loaded
    if (subscriptionProvider.subscription == null) {
      await subscriptionProvider.loadSubscription();
    }
    
    final isPremium = subscriptionProvider.isPremium;

    // Premium features: Trends (1), Boost (2), Analytics (3), AI Bot (4)
    final isPremiumItem = index == 1 || index == 3 || index == 4 || index == 2;
    
    if (isPremiumItem && !isPremium) {
      Navigator.pushNamed(context, '/subscription');
      return;
    }

    if (index == 2) {
      openBoostSheet();
      return;
    }

    if (routes[index] == null) return;

    HapticFeedback.selectionClick();

    setState(() => selectedIndex = index);

    Navigator.pushNamed(context, routes[index]!).then((_) {
      if (mounted) {
        setState(() => selectedIndex = -1);
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F3FF),

      body: SafeArea(
        child: Stack(
          children: [

            /// Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: kBottomNavHeight + 30,
              ),

              child: Column(
                children: [

                  const SizedBox(height: 5),

                  _topBar(),


                  const SizedBox(height: 20),

                  Consumer<PlatformProvider>(
                    builder: (context, platformProvider, child) {
                      return PostTodoWidget(key: ValueKey(platformProvider.selectedPlatform));
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),

            /// Floating + Button
            _buildFab(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTap: _onItemTap,
        visible: _navVisible,
      ),
    );
  }

  
  Widget _buildFab() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: kBottomNavHeight - 2 * kFabSize + 10,
      right: 20,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: 1,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/post');
          },
          child: Container(
            width: kFabSize,
            height: kFabSize,
            decoration: BoxDecoration(
              color: const Color(0xff6A5AE0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      child: Row(
        children: [

          IconButton(
            icon: const Icon(Icons.settings),

            onPressed: () =>
                Navigator.pushNamed(context, '/profile'),
          ),

          const Spacer(),

          Image.asset(
            'assets/images/small_logo.png',
            height: 36,
          ),

          const Spacer(),


          _buildPlatformSelector(),


        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Consumer<PlatformProvider>(
      builder: (context, platformProvider, child) {
        final config = platformProvider.currentConfig;
        
        return GestureDetector(
          onTap: () => _showPlatformSelector(context, platformProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            decoration: BoxDecoration(


            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  config.iconPath,
                  width: 40,
                  height: 40,
                ),


              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlatformSelector(BuildContext context, PlatformProvider platformProvider) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlatformSelectorSheet(
        currentPlatformId: platformProvider.selectedPlatform,
        onPlatformSelected: (platformId) {
          platformProvider.setSelectedPlatform(platformId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMultiPlatformSelector(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MultiPlatformSelectorSheet(
        onPlatformsSelected: (selectedPlatforms) {
          Navigator.pop(context);
          if (selectedPlatforms.isNotEmpty) {
            Navigator.pushNamed(
              context,
              '/post',
              arguments: {'date': null, 'platforms': selectedPlatforms},
            );
          }
        },
      ),
    );
  }

  void _openAccountSwitcher() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _accountSwitcherSheet(),
    );
  }


  Widget _accountSwitcherSheet() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [


          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            "Switch Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ...accounts.map(_buildAccountTile).toList(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAccountTile(SocialAccount account) {
    return ListTile(

      leading: CircleAvatar(
        backgroundImage: AssetImage(account.logo),
        backgroundColor: Colors.transparent,
      ),

      title: Text(account.name),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: () {

        Navigator.pop(context);

        _openSelectedAccount(account);
      },
    );
  }

  void _openSelectedAccount(SocialAccount account) {

    final app = account.name.toLowerCase();

    if (account.connected) {

      Navigator.pushNamed(
        context,
        '/$app',
        arguments: account.profile,
      );

    } else {

      Navigator.pushNamed(context, '/login-$app').then((result) {

        if (result == true) {
          _loadAccounts();
        }
      });
    }
  }

  Widget _socialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: accounts.map(buildSocialButton).toList(),
    );
  }

  Widget buildSocialButton(SocialAccount account) {

    return GestureDetector(
      onTap: () => handleSocialTap(account),

      child: Stack(
        clipBehavior: Clip.none,

        children: [

          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff6A5AE0),
                  Color(0xff00D4FF),
                ],
              ),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Center(
              child: Image.asset(account.logo, width: 36),
            ),
          ),


        ],
      ),
    );
  }

  
  void handleSocialTap(SocialAccount account) async {

    final app = account.name.toLowerCase();

    if (account.connected) {

      Navigator.pushNamed(
        context,
        '/$app',
        arguments: account.profile,
      );

    } else {

      final result =
      await Navigator.pushNamed(context, '/$app');

      if (result == true) {
        _loadAccounts();
      }
    }
  }
}

class _PlatformSelectorSheet extends StatelessWidget {
  final String currentPlatformId;
  final Function(String) onPlatformSelected;

  const _PlatformSelectorSheet({
    required this.currentPlatformId,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Select Platform",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...platforms.map((platform) {
            final isSelected = platform.id == currentPlatformId;
            return _buildPlatformTile(platform, isSelected);
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPlatformTile(PlatformConfig platform, bool isSelected) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: platform.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            platform.iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
      title: Text(
        platform.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: platform.color)
          : Icon(Icons.circle_outlined, color: Colors.grey[300]),
      onTap: () => onPlatformSelected(platform.id),
    );
  }
}

class _MultiPlatformSelectorSheet extends StatefulWidget {
  final Function(List<String>) onPlatformsSelected;

  const _MultiPlatformSelectorSheet({
    required this.onPlatformsSelected,
  });

  @override
  State<_MultiPlatformSelectorSheet> createState() => _MultiPlatformSelectorSheetState();
}

class _MultiPlatformSelectorSheetState extends State<_MultiPlatformSelectorSheet> {
  final Set<String> _selectedPlatforms = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Select Platforms",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Choose one or more platforms to post",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ...platforms.map((platform) {
            final isSelected = _selectedPlatforms.contains(platform.id);
            return _buildPlatformTile(platform, isSelected);
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPlatforms.isEmpty
                  ? null
                  : () => widget.onPlatformsSelected(_selectedPlatforms.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedPlatforms.isEmpty
                    ? "Select at least one platform"
                    : "Continue with ${_selectedPlatforms.length} platform${_selectedPlatforms.length > 1 ? 's' : ''}",
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPlatformTile(PlatformConfig platform, bool isSelected) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: platform.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            platform.iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
      title: Text(
        platform.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: platform.color)
          : Icon(Icons.circle_outlined, color: Colors.grey[300]),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPlatforms.remove(platform.id);
          } else {
            _selectedPlatforms.add(platform.id);
          }
        });
      },
    );
  }
}

class PostTodoWidget extends StatefulWidget {
  const PostTodoWidget({super.key});

  @override
  State<PostTodoWidget> createState() => _PostTodoWidgetState();
}

class _PostTodoWidgetState extends State<PostTodoWidget> {
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  Future<void> _loadPosts() async {
    try {
      final platformProvider = context.read<PlatformProvider>();
      final platformApiName = platformProvider.currentConfig.apiName;
      
      final posts = await ApiService.getUserPosts(

        limit: 15,
        platform: platformApiName,
      );
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return const SizedBox.shrink();
    }
    
    final displayPosts = _posts.where((p) => 
      p.status == PostStatus.scheduled ||
      p.status == PostStatus.published ||
      p.status == PostStatus.failed
    ).toList();

    displayPosts.sort((a, b) {
      final aIsScheduled = a.status == PostStatus.scheduled;
      final bIsScheduled = b.status == PostStatus.scheduled;
      if (aIsScheduled != bIsScheduled) {
        return aIsScheduled ? -1 : 1;
      }
      final aTime = a.scheduledTime ?? a.createdAt;
      final bTime = b.scheduledTime ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    final limitedPosts = displayPosts.take(8).toList();

    if (limitedPosts.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        itemCount: limitedPosts.length,
        itemBuilder: (context, index) {
          final post = limitedPosts[index];
          return _buildPostTile(post);
        },
      ),
    );
  }

  Widget _buildPostTile(Post post) {
    IconData statusIcon;
    Color statusColor;
    
    switch (post.status) {
      case PostStatus.scheduled:
        statusIcon = Icons.schedule;
        statusColor = const Color(0xFF6A5AE0);
        break;
      case PostStatus.published:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case PostStatus.failed:
        statusIcon = Icons.error;
        statusColor = Colors.red;
        break;
      default:
        statusIcon = Icons.help;
        statusColor = Colors.grey;
    }

    final dateTime = post.scheduledTime ?? post.createdAt;
    final dateTimeStr = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content.length > 40 ? '${post.content.substring(0, 40)}...' : post.content,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateTimeStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(statusIcon, color: statusColor, size: 24),
        ],
      ),
    );
  }
}