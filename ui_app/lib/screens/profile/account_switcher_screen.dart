import 'package:flutter/material.dart';
import '../../services/account_service.dart';

class AccountSwitcherScreen extends StatefulWidget {
  const AccountSwitcherScreen({super.key});

  @override
  State<AccountSwitcherScreen> createState() => _AccountSwitcherScreenState();
}

class _AccountSwitcherScreenState extends State<AccountSwitcherScreen> {
  bool isLoading = true;
  String? selectedPlatform;
  List<Map<String, dynamic>> accounts = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AccountService.getConnectedAccounts();
      setState(() {
        accounts = List<Map<String, dynamic>>.from(data['accounts'] ?? []);
        selectedPlatform = data['activePlatform'];
        
        // If no active platform, set first connected as active
        if (selectedPlatform == null && accounts.isNotEmpty) {
          selectedPlatform = accounts[0]['platform'];
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _setActivePlatform(String platform) async {
    try {
      await AccountService.setActiveAccount(platform);
      setState(() {
        selectedPlatform = platform;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${_getPlatformDisplayName(platform)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.black;
      case 'linkedin':
        return const Color(0xFF0A66C2);
      default:
        return Colors.grey;
    }
  }

  Widget _buildPlatformIcon(String platform, {double size = 32}) {
    try {
      return Image.asset(
        'assets/images/social/${platform == 'twitter' ? 'x' : platform == 'instagram' ? 'ig' : platform == 'facebook' ? 'fb' : platform}.png',
        width: size,
        height: size,
      );
    } catch (e) {
      return Icon(Icons.account_circle, size: size);
    }
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'twitter':
        return 'Twitter / X';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('switching account'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account Switcher'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAccounts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (accounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Account Switcher'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No accounts connected'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/social-profiles');
                },
                child: const Text('Connect Accounts'),
              ),
            ],
          ),
        ),
      );
    }

    final currentAccount = accounts.firstWhere(
      (acc) => acc['platform'] == selectedPlatform,
      orElse: () => accounts[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildPlatformIcon(selectedPlatform ?? 'instagram', size: 28),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(currentAccount),

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
                  ...accounts.map((account) => _buildAccountTile(account)),
                  const SizedBox(height: 16),
                  _buildAddAccountButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> account) {
    final String platform = account['platform'] ?? 'instagram';
    final String name = account['name'] ?? 'User';
    final String handle = account['handle'] ?? '';
    final String bio = account['bio'] ?? 'Not to miss the "chill" in chhillar.';
    final String avatar = account['avatar'] ?? '';
    final int followers = account['followers'] ?? 0;
    final int following = account['following'] ?? 0;
    final int posts = account['posts'] ?? 0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Cover Photo
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getPlatformColor(platform).withOpacity(0.1),
            ),
            child: avatar.isNotEmpty
                ? Image.network(avatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container())
                : null,
          ),
          
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar.isEmpty
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
                if (handle.isNotEmpty)
                  Text(
                    handle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Stats
                if (platform == 'instagram' || platform == 'twitter')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(posts.toString(), 'Posts'),
                        _buildStat(_formatNumber(followers), 'Followers'),
                        _buildStat(_formatNumber(following), 'Following'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
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
    final String platform = account['platform'] ?? '';
    final String name = account['name'] ?? '';
    final bool isActive = account['platform'] == selectedPlatform;

    return GestureDetector(
      onTap: () => _setActivePlatform(platform),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF0095F6)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            _buildPlatformIcon(platform),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF0095F6)
                      : Colors.grey,
                  width: 2,
                ),
                color: isActive
                    ? const Color(0xFF0095F6)
                    : Colors.transparent,
              ),
              child: isActive
                  ? const Icon(Icons.circle, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/social-profiles');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
