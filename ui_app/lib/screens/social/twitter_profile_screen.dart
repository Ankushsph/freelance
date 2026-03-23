import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/social_profile.dart';
import '../../../services/auth_storage.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TwitterProfileScreen extends StatefulWidget {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  const TwitterProfileScreen({super.key});

  @override
  State<TwitterProfileScreen> createState() => _TwitterProfileScreenState();
}

class _TwitterProfileScreenState extends State<TwitterProfileScreen> {
  SocialProfile? profile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {

      final stored = await AuthStorage.getStoredTwitterProfile();
      
      if (stored != null) {
        setState(() {
          profile = _mapToSocialProfile(stored);
          isLoading = false;
        });
        

        _refreshFromApi();
      } else {

        await _refreshFromApi();
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load profile';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshFromApi() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        setState(() {
          profile = null;
          isLoading = false;
        });
        return;
      }

      final data = await ApiService.getTwitterProfile();
      await AuthStorage.saveTwitterProfile(data);
      
      if (mounted) {
        setState(() {
          profile = _mapToSocialProfile(data);
          isLoading = false;
        });
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          if (profile == null) {
            isLoading = false;
            error = null;
          }
        });
      }
    }
  }

  SocialProfile _mapToSocialProfile(Map<String, dynamic> data) {
    final String username =
        data['username'] != null ? '@${data['username']}' : '';

    return SocialProfile(
      name: data['name'] ?? 'X User',
      username: username,
      bio: '',
      profileImage: '',
      location: 'X',
      stats: {
        'ID': (data['id'] ?? 'N/A').toString().substring(0, 8) + '...',
      },
      connected: true,
    );
  }

  Future<void> _connectTwitter() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt == null) {
      _showError("You must be logged in first");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('${TwitterProfileScreen.baseUrl}/twitter/connect'),
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode != 200) {
        final msg = jsonDecode(res.body)['message'] ?? 'OAuth failed';
        throw Exception(msg);
      }

      final data = jsonDecode(res.body);
      final oauthUrl = Uri.parse(data['url']);

      final launched = await launchUrl(
        oauthUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception("Could not open Twitter OAuth");
      }
      

    } catch (e) {
      _showError("Error: $e");
    }
  }

  Future<void> _disconnect() async {

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect X?'),
        content: const Text('This will remove your X connection from both app and server. You can reconnect anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1DA1F2)),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;


    if (mounted) {
      setState(() {
        profile = null;
      });
    }
    await AuthStorage.clearTwitterProfile();

    try {

      await ApiService.disconnectTwitter();
    } catch (e) {

      print('Warning: Backend disconnect failed: $e');
    }

    if (mounted) {
      _showSuccess('X disconnected successfully');

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1DA1F2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xff1a1a1a),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    if (profile == null || error != null) {
      return _buildConnectScreen();
    }

    return _buildProfileScreen(profile!);
  }

  Widget _buildConnectScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xff1a1a1a),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(showRefresh: false),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '𝕏',
                        style: TextStyle(
                          fontSize: 80,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connect X',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Post and schedule content\ndirectly to your X',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _connectTwitter,
                        icon: const Icon(Icons.login),
                        label: const Text('Connect Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileScreen(SocialProfile p) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xff1a1a1a),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(showRefresh: true),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black,
                        child: p.profileImage.isNotEmpty
                            ? null
                            : const Text(
                                '𝕏',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (p.username.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          p.username,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (p.bio.isNotEmpty)
                        Text(
                          p.bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: p.stats.entries
                            .map((e) => _buildStat(e.value, e.key))
                            .toList(),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _disconnect,
                          icon: const Icon(Icons.logout),
                          label: const Text('Disconnect Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DA1F2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool showRefresh}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const Spacer(),
          const Text(
            'X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (showRefresh)
            GestureDetector(
              onTap: _loadProfile,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
            )
          else
            const SizedBox(width: 40),
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
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}