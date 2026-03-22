import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/social_profile.dart';
import '../../../services/auth_storage.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class InstagramProfileScreen extends StatefulWidget {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  const InstagramProfileScreen({super.key});

  @override
  State<InstagramProfileScreen> createState() => _InstagramProfileScreenState();
}

class _InstagramProfileScreenState extends State<InstagramProfileScreen> with WidgetsBindingObserver {
  SocialProfile? profile;
  bool isLoading = true;
  String? error;
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isCheckingConnection) {
      // App came back to foreground - check if Instagram was connected
      _checkConnectionAfterOAuth();
    }
  }

  Future<void> _checkConnectionAfterOAuth() async {
    if (_isCheckingConnection) return;
    
    _isCheckingConnection = true;
    
    // Wait a bit for the backend to process the OAuth callback
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      await _refreshFromApi();
      if (profile != null && mounted) {
        _showSuccess('Instagram connected successfully!');
      }
    } catch (e) {
      print('Connection check failed: $e');
    } finally {
      _isCheckingConnection = false;
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {

      final stored = await AuthStorage.getStoredInstagramProfile();
      
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

      final data = await ApiService.getInstagramProfile(token: token);
      await AuthStorage.saveInstagramProfile(data);
      
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
      name: data['name'] ?? 'Instagram User',
      username: username,
      bio: data['biography'] ?? '',
      profileImage: data['profile_picture_url'] ?? '',
      location: 'Instagram',
      stats: {
        'Posts': (data['media_count'] ?? 0).toString(),
        'Followers': (data['followers_count'] ?? 0).toString(),
        'Following': (data['follows_count'] ?? 0).toString(),
      },
      connected: true,
    );
  }

  Future<void> _connectInstagram() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt == null) {
      _showError("You must be logged in first");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final res = await http.post(
        Uri.parse('${InstagramProfileScreen.baseUrl}/instagram/connect'),
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

      setState(() {
        isLoading = false;
      });

      final launched = await launchUrl(
        oauthUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception("Could not open Instagram OAuth");
      }
      
      // Show a message that user should return after connecting
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete the login in your browser, then return to the app'),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.blue,
          ),
        );
      }

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError("Error: $e");
    }
  }

  Future<void> _disconnect() async {

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Instagram?'),
        content: const Text('This will remove your Instagram connection from both app and server. You can reconnect anytime.'),
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


    if (mounted) {
      setState(() {
        profile = null;
      });
    }
    await AuthStorage.clearInstagramProfile();

    try {

      await ApiService.disconnectInstagram();
    } catch (e) {

      print('Warning: Backend disconnect failed: $e');
    }

    if (mounted) {
      _showSuccess('Instagram disconnected successfully');

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
        backgroundColor: Colors.red,
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
                Color(0xffFEDA75),
                Color(0xffFA7E1E),
                Color(0xffD62976),
                Color(0xff962FBF),
                Color(0xff4F5BD5),
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
              Color(0xffFEDA75),
              Color(0xffFA7E1E),
              Color(0xffD62976),
              Color(0xff962FBF),
              Color(0xff4F5BD5),
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
                      const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connect Instagram',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Post and schedule content\ndirectly to your Instagram',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _connectInstagram,
                        icon: const Icon(Icons.login),
                        label: const Text('Connect Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xffD62976),
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
              Color(0xffFEDA75),
              Color(0xffFA7E1E),
              Color(0xffD62976),
              Color(0xff962FBF),
              Color(0xff4F5BD5),
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
                        backgroundImage: p.profileImage.isNotEmpty
                            ? NetworkImage(p.profileImage)
                            : null,
                        child: p.profileImage.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
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
                            backgroundColor: Colors.red.shade400,
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
            'Instagram',
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