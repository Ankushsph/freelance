import 'package:flutter/material.dart';
import '../../services/auth_storage.dart';
import '../../services/api_service.dart';

class SocialProfilesScreen extends StatefulWidget {
  const SocialProfilesScreen({super.key});

  @override
  State<SocialProfilesScreen> createState() => _SocialProfilesScreenState();
}

class _SocialProfilesScreenState extends State<SocialProfilesScreen> {
  bool isLoading = true;
  Map<String, dynamic>? instagramProfile;
  Map<String, dynamic>? facebookProfile;
  Map<String, dynamic>? linkedinProfile;
  Map<String, dynamic>? twitterProfile;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSocialProfiles();
  }

  Future<void> _loadSocialProfiles() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      instagramProfile = await AuthStorage.getStoredInstagramProfile();
      facebookProfile = await AuthStorage.getStoredFacebookProfile();
      linkedinProfile = await AuthStorage.getStoredLinkedInProfile();
      twitterProfile = await AuthStorage.getStoredTwitterProfile();

      await _fetchFreshData();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchFreshData() async {
    try {
      try {
        final igData = await ApiService.getInstagramProfile(token: '');
        setState(() {
          instagramProfile = igData;
        });
      } catch (e) {
      }

      try {
        final fbData = await ApiService.getFacebookProfile();
        setState(() {
          facebookProfile = fbData;
        });
      } catch (e) {
      }

      try {
        final liData = await ApiService.getLinkedInProfile();
        setState(() {
          linkedinProfile = liData;
        });
      } catch (e) {
      }

      try {
        final twData = await ApiService.getTwitterProfile();
        setState(() {
          twitterProfile = twData;
        });
      } catch (e) {
      }
    } catch (e) {
      print('Error fetching fresh data: $e');
    }
  }

  Widget _buildSocialCard({
    required String platform,
    required String logoPath,
    required Color color,
    required Map<String, dynamic>? profile,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    final isConnected = profile != null;
    final username = profile?['username'] ?? profile?['name'] ?? 'Not connected';
    final followers = profile?['followers_count'] ?? profile?['followers'] ?? 0;
    final following = profile?['following_count'] ?? profile?['following'] ?? 0;
    final posts = profile?['posts_count'] ?? profile?['posts'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Image.asset(logoPath, width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isConnected ? '@$username' : 'Not connected',
                        style: TextStyle(
                          fontSize: 14,
                          color: isConnected ? Colors.green : Colors.grey,
                          fontWeight: isConnected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Posts', posts.toString()),
                  _buildStat('Followers', _formatNumber(followers)),
                  _buildStat('Following', _formatNumber(following)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDisconnect,
                  icon: const Icon(Icons.link_off, size: 18),
                  label: const Text('Disconnect'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Connect Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatNumber(dynamic num) {
    if (num == null) return '0';
    final n = num is int ? num : int.tryParse(num.toString()) ?? 0;
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }

  void _connectPlatform(String platform) {
    final routeMap = {
      'instagram': '/instagram',
      'facebook': '/facebook',
      'linkedin': '/linkedin',
      'twitter': '/x',
    };
    final route = routeMap[platform.toLowerCase()];
    if (route != null) {
      Navigator.pushNamed(context, route).then((result) {
        if (result == true) {
          _loadSocialProfiles();
        }
      });
    }
  }

  Future<void> _disconnectPlatform(String platform) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Account'),
        content: Text('Are you sure you want to disconnect your $platform account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      switch (platform.toLowerCase()) {
        case 'instagram':
          await ApiService.disconnectInstagram();
          await AuthStorage.clearInstagramProfile();
          break;
        case 'facebook':
          await ApiService.disconnectFacebook();
          await AuthStorage.clearFacebookProfile();
          break;
        case 'linkedin':
          await ApiService.disconnectLinkedIn();
          await AuthStorage.clearLinkedInProfile();
          break;
        case 'twitter':
          await ApiService.disconnectTwitter();
          await AuthStorage.clearTwitterProfile();
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform disconnected successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _loadSocialProfiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to disconnect: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Social Profiles',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: isLoading ? null : _loadSocialProfiles,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSocialProfiles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSocialProfiles,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSocialCard(
                        platform: 'Instagram',
                        logoPath: 'assets/images/social/ig.png',
                        color: const Color(0xFFE4405F),
                        profile: instagramProfile,
                        onConnect: () => _connectPlatform('instagram'),
                        onDisconnect: () => _disconnectPlatform('Instagram'),
                      ),
                      _buildSocialCard(
                        platform: 'Facebook',
                        logoPath: 'assets/images/social/fb.png',
                        color: const Color(0xFF1877F2),
                        profile: facebookProfile,
                        onConnect: () => _connectPlatform('facebook'),
                        onDisconnect: () => _disconnectPlatform('Facebook'),
                      ),
                      _buildSocialCard(
                        platform: 'LinkedIn',
                        logoPath: 'assets/images/social/linkedin.png',
                        color: const Color(0xFF0A66C2),
                        profile: linkedinProfile,
                        onConnect: () => _connectPlatform('linkedin'),
                        onDisconnect: () => _disconnectPlatform('LinkedIn'),
                      ),
                      _buildSocialCard(
                        platform: 'Twitter / X',
                        logoPath: 'assets/images/social/x.png',
                        color: Colors.black,
                        profile: twitterProfile,
                        onConnect: () => _connectPlatform('twitter'),
                        onDisconnect: () => _disconnectPlatform('Twitter'),
                      ),
                    ],
                  ),
                ),
    );
  }
}