import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/api_service.dart';
import '../../services/auth_storage.dart';

class UnifiedProfileScreen extends StatefulWidget {
  const UnifiedProfileScreen({super.key});

  @override
  State<UnifiedProfileScreen> createState() => _UnifiedProfileScreenState();
}

class _UnifiedProfileScreenState extends State<UnifiedProfileScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> connectedAccounts = [];
  String? activeAccountId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load user data
      userData = await ApiService.getMe();
      
      // Load connected accounts
      final accounts = await _fetchConnectedAccounts();
      
      setState(() {
        connectedAccounts = accounts;
        activeAccountId = userData?['activeAccountId'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchConnectedAccounts() async {
    List<Map<String, dynamic>> accounts = [];

    // Try to fetch each platform's profile
    try {
      final ig = await ApiService.getInstagramProfile();
      accounts.add({
        'platform': 'instagram',
        'name': ig['username'] ?? 'Instagram',
        'handle': '@${ig['username'] ?? ''}',
        'followers': ig['followers_count'] ?? 0,
        'avatar': ig['profile_picture_url'] ?? '',
        'isActive': false,
      });
    } catch (e) {}

    try {
      final fb = await ApiService.getFacebookProfile();
      accounts.add({
        'platform': 'facebook',
        'name': fb['name'] ?? 'Facebook',
        'handle': fb['name'] ?? '',
        'followers': 0,
        'avatar': fb['picture']?['data']?['url'] ?? '',
        'isActive': false,
      });
    } catch (e) {}

    try {
      final tw = await ApiService.getTwitterProfile();
      accounts.add({
        'platform': 'twitter',
        'name': tw['name'] ?? 'Twitter',
        'handle': '@${tw['username'] ?? ''}',
        'followers': tw['followers_count'] ?? 0,
        'avatar': tw['profile_image_url'] ?? '',
        'isActive': false,
      });
    } catch (e) {}

    try {
      final li = await ApiService.getLinkedInProfile();
      accounts.add({
        'platform': 'linkedin',
        'name': li['name'] ?? 'LinkedIn',
        'handle': li['name'] ?? '',
        'followers': 0,
        'avatar': '',
        'isActive': false,
      });
    } catch (e) {}

    return accounts;
  }

  Widget _buildPlatformIcon(String platform) {
    switch (platform) {
      case 'instagram':
        return Image.asset('assets/images/social/ig.png', width: 32, height: 32);
      case 'facebook':
        return Image.asset('assets/images/social/fb.png', width: 32, height: 32);
      case 'twitter':
        return Image.asset('assets/images/social/x.png', width: 32, height: 32);
      case 'linkedin':
        return Image.asset('assets/images/social/linkedin.png', width: 32, height: 32);
      default:
        return const Icon(Icons.account_circle, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Switching Account'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Image.asset('assets/images/logo.png', height: 32),
        actions: [
          IconButton(
            icon: _buildPlatformIcon(connectedAccounts.isNotEmpty ? connectedAccounts[0]['platform'] : 'instagram'),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            if (connectedAccounts.isNotEmpty) _buildProfileHeader(connectedAccounts[0]),
            
            const SizedBox(height: 24),
            
            // Accounts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...connectedAccounts.map((account) => _buildAccountTile(account)),
                  const SizedBox(height: 16),
                  _buildAddAccountButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> account) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cover Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundImage: account['avatar'] != null && account['avatar'].isNotEmpty
                ? NetworkImage(account['avatar'])
                : null,
            child: account['avatar'] == null || account['avatar'].isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 12),
          // Name
          Text(
            account['name'] ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            account['handle'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Not to miss the "chill" in chhillar.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('772', 'Posts'),
              _buildStat('${(account['followers'] / 1000000).toStringAsFixed(1)}M', 'Followers'),
              _buildStat('251', 'Following'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile(Map<String, dynamic> account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPlatformIcon(account['platform']),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              account['name'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: account['isActive'],
            onChanged: (value) {
              // TODO: Set active account
            },
            activeColor: const Color(0xFF0095F6),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0095F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Add account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.add, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
