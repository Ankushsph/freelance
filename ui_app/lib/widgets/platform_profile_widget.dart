import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class PlatformProfileWidget extends StatefulWidget {
  final String platformId;

  const PlatformProfileWidget({
    super.key,
    required this.platformId,
  });

  @override
  State<PlatformProfileWidget> createState() => _PlatformProfileWidgetState();
}

class _PlatformProfileWidgetState extends State<PlatformProfileWidget> {
  Map<String, dynamic>? profileData;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(PlatformProfileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.platformId != widget.platformId) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);

    try {
      final platformName = _getPlatformApiName(widget.platformId);
      
      // Load profile data
      Map<String, dynamic>? profile;
      switch (platformName) {
        case 'instagram':
          profile = await AuthStorage.getStoredInstagramProfile();
          if (profile == null) {
            profile = await ApiService.getInstagramProfile();
          }
          break;
        case 'facebook':
          profile = await AuthStorage.getStoredFacebookProfile();
          if (profile == null) {
            profile = await ApiService.getFacebookProfile();
          }
          break;
        case 'linkedin':
          profile = await AuthStorage.getStoredLinkedInProfile();
          if (profile == null) {
            profile = await ApiService.getLinkedInProfile();
          }
          break;
        case 'twitter':
          profile = await AuthStorage.getStoredTwitterProfile();
          if (profile == null) {
            profile = await ApiService.getTwitterProfile();
          }
          break;
      }

      // Load posts
      final userPosts = await ApiService.getUserPosts(
        limit: 9,
        platform: platformName,
      );

      if (mounted) {
        setState(() {
          profileData = profile;
          posts = userPosts.map((p) => {
            'id': p.id,
            'content': p.content,
            'mediaUrl': p.mediaUrl,
            'createdAt': p.createdAt,
          }).toList();
          isConnected = profile != null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isConnected = false;
          isLoading = false;
        });
      }
    }
  }

  String _getPlatformApiName(String platformId) {
    switch (platformId) {
      case 'IG':
        return 'instagram';
      case 'FB':
        return 'facebook';
      case 'LN':
        return 'linkedin';
      case 'X':
        return 'twitter';
      default:
        return 'instagram';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!isConnected || profileData == null) {
      return _buildConnectPrompt();
    }

    switch (widget.platformId) {
      case 'IG':
        return _buildInstagramProfile();
      case 'FB':
        return _buildFacebookProfile();
      case 'LN':
        return _buildLinkedInProfile();
      case 'X':
        return _buildTwitterProfile();
      default:
        return _buildInstagramProfile();
    }
  }

  Widget _buildConnectPrompt() {
    final platformName = _getPlatformName(widget.platformId);
    final platformColor = _getPlatformColor(widget.platformId);

    return Container(
      height: MediaQuery.of(context).size.height - 200,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPlatformIcon(widget.platformId),
              size: 80,
              color: platformColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Connect $platformName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect your $platformName account to see your profile and manage posts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/${widget.platformId.toLowerCase()}')
                    .then((_) => _loadProfile());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: platformColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Connect $platformName Account'),
            ),
          ],
        ),
      ),
    );
  }

  // Instagram Profile
  Widget _buildInstagramProfile() {
    final username = profileData!['username'] ?? 'user';
    final name = profileData!['name'] ?? 'User';
    final bio = profileData!['biography'] ?? '';
    final profilePic = profileData!['profile_picture_url'] ?? '';
    final postsCount = profileData!['media_count'] ?? posts.length;
    final followersCount = profileData!['followers_count'] ?? 0;
    final followingCount = profileData!['follows_count'] ?? 0;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePic.isNotEmpty
                      ? NetworkImage(profilePic)
                      : null,
                  child: profilePic.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 24),
                // Stats
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(postsCount.toString(), 'posts'),
                      _buildStat(_formatCount(followersCount), 'followers'),
                      _buildStat(_formatCount(followingCount), 'following'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Name and Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/instagram');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Posts Grid
          _buildPostsGrid(),
        ],
      ),
    );
  }

  // Facebook Profile
  Widget _buildFacebookProfile() {
    final name = profileData!['name'] ?? 'User';
    final profilePic = profileData!['picture']?['data']?['url'] ?? '';
    final friendsCount = profileData!['friends_count'] ?? 0;

    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          // Cover Photo
          Container(
            height: 150,
            color: const Color(0xFF1877F2),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: profilePic.isNotEmpty
                        ? NetworkImage(profilePic)
                        : null,
                    child: profilePic.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$friendsCount friends',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/facebook');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Posts
                _buildPostsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LinkedIn Profile
  Widget _buildLinkedInProfile() {
    final name = profileData!['name'] ?? 'User';
    final email = profileData!['email'] ?? '';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0077B5).withOpacity(0.3),
                  const Color(0xFF005885).withOpacity(0.3),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF0077B5),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  '500+ connections',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0077B5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/linkedin');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('View Profile'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPostsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Twitter/X Profile
  Widget _buildTwitterProfile() {
    final name = profileData!['name'] ?? 'User';
    final username = profileData!['username'] ?? 'user';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1a1a1a)],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -50),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    child: Text(
                      '𝕏',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/x');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('View Profile'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPostsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: posts.length > 9 ? 9 : posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final mediaUrl = post['mediaUrl'];

        return Container(
          color: Colors.grey[200],
          child: mediaUrl != null && mediaUrl.isNotEmpty
              ? Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                )
              : Center(
                  child: Icon(Icons.article, color: Colors.grey[400]),
                ),
        );
      },
    );
  }

  Widget _buildPostsList() {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No posts yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: posts.length > 5 ? 5 : posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['content'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post['mediaUrl'] != null && post['mediaUrl'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post['mediaUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _getPlatformName(String platformId) {
    switch (platformId) {
      case 'IG':
        return 'Instagram';
      case 'FB':
        return 'Facebook';
      case 'LN':
        return 'LinkedIn';
      case 'X':
        return 'X';
      default:
        return 'Instagram';
    }
  }

  Color _getPlatformColor(String platformId) {
    switch (platformId) {
      case 'IG':
        return const Color(0xFFE4405F);
      case 'FB':
        return const Color(0xFF1877F2);
      case 'LN':
        return const Color(0xFF0077B5);
      case 'X':
        return Colors.black;
      default:
        return const Color(0xFF1DA1F2);
    }
  }

  IconData _getPlatformIcon(String platformId) {
    switch (platformId) {
      case 'IG':
        return Icons.camera_alt;
      case 'FB':
        return Icons.facebook;
      case 'LN':
        return Icons.business;
      case 'X':
        return Icons.close;
      default:
        return Icons.camera_alt;
    }
  }
}
