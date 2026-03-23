import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/social_profile.dart';
import '../../../services/auth_storage.dart';
import '../../../services/api_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'dart:async';

class FacebookProfileScreen extends StatefulWidget {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;
  const FacebookProfileScreen({super.key});

  @override
  State<FacebookProfileScreen> createState() => _FacebookProfileScreenState();
}

class _FacebookProfileScreenState extends State<FacebookProfileScreen> {
  SocialProfile? profile;
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> pages = [];
  String? selectedPageId;
  bool isLoadingPages = false;
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    print('[FacebookScreen] initState called');
    _loadProfile();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.toString().contains('oauth/facebook/success')) {
        _handleOAuthSuccess();
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  Future<void> _handleOAuthSuccess() async {
    await Future.delayed(const Duration(seconds: 1));
    await _refreshFromApi();
    if (profile != null && mounted) {
      _showSuccess('Facebook connected successfully!');
    }
  }

  Future<void> _loadProfile() async {
    print('[FacebookScreen] _loadProfile started');
    setState(() {
      isLoading = true;
      error = null;
    });

    try {

      final stored = await AuthStorage.getStoredFacebookProfile();
      print('[FacebookScreen] Stored profile: $stored');
      
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
      print('[FacebookScreen] Error in _loadProfile: $e');
      setState(() {
        error = 'Failed to load profile';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshFromApi() async {
    print('[FacebookScreen] _refreshFromApi started');
    try {
      final data = await ApiService.getFacebookProfile();
      print('[FacebookScreen] API success: $data');
      await AuthStorage.saveFacebookProfile(data);
      
      if (mounted) {
        setState(() {
          profile = _mapToSocialProfile(data);
          isLoading = false;
          error = null;
        });
        

        _loadPages();
      }
    } catch (e) {
      print('[FacebookScreen] API error: $e');

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

  Future<void> _loadPages() async {
    setState(() {
      isLoadingPages = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');

      if (jwt == null) return;

      final res = await http.get(
        Uri.parse('${FacebookProfileScreen.baseUrl}/facebook/pages'),
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          pages = List<Map<String, dynamic>>.from(data['pages'] ?? []);
          selectedPageId = data['selectedPageId'];
          isLoadingPages = false;
        });
      }
    } catch (e) {
      print('[FacebookScreen] Error loading pages: $e');
      setState(() {
        isLoadingPages = false;
      });
    }
  }

  Future<void> _selectPage(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt_token');

      if (jwt == null) return;

      final res = await http.post(
        Uri.parse('${FacebookProfileScreen.baseUrl}/facebook/select-page'),
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'pageId': pageId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          selectedPageId = pageId;
        });
        _showSuccess('Page "${data['page']['name']}" selected successfully');
      } else {
        final error = jsonDecode(res.body);
        _showError(error['message'] ?? 'Failed to select page');
      }
    } catch (e) {
      _showError('Error selecting page: $e');
    }
  }

  SocialProfile _mapToSocialProfile(Map<String, dynamic> data) {
    return SocialProfile(
      name: data['name'] ?? 'Facebook User',
      username: data['username'] != null ? '@${data['username']}' : '',
      bio: data['bio'] ?? '',
      profileImage: data['picture']?['data']?['url'] ?? '',
      location: 'Facebook',
      stats: {
        'Friends': (data['friends_count'] ?? 0).toString(),
        'Posts': (data['posts_count'] ?? 0).toString(),
        'Likes': (data['likes_count'] ?? 0).toString(),
      },
      connected: true,
    );
  }

  Future<void> _connectFacebook() async {
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
        Uri.parse('${FacebookProfileScreen.baseUrl}/facebook/connect'),
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
        throw Exception("Could not open Facebook OAuth");
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
        title: const Text('Disconnect Facebook?'),
        content: const Text('This will remove your Facebook connection from both app and server. You can reconnect anytime.'),
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

    print('[FacebookScreen] Disconnecting...');
    

    if (mounted) {
      setState(() {
        profile = null;
      });
    }
    await AuthStorage.clearFacebookProfile();
    print('[FacebookScreen] Local storage cleared');

    try {

      await ApiService.disconnectFacebook();
    } catch (e) {

      print('Warning: Backend disconnect failed: $e');
    }

    if (mounted) {
      _showSuccess('Facebook disconnected successfully');

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
    print('[FacebookScreen] build: isLoading=$isLoading, profile=$profile, error=$error');
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xff1877F2),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      backgroundColor: const Color(0xff1877F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(showRefresh: false),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.facebook,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Connect Facebook',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Post and schedule content\ndirectly to your Facebook Page',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _connectFacebook,
                      icon: const Icon(Icons.login),
                      label: const Text('Connect Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff1877F2),
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
    );
  }

  Widget _buildProfileScreen(SocialProfile p) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(showRefresh: true),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 150,
                          color: const Color(0xff1877F2),
                        ),
                        Positioned(
                          bottom: -50,
                          left: 20,
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundImage: p.profileImage.isNotEmpty
                                  ? NetworkImage(p.profileImage)
                                  : null,
                              child: p.profileImage.isEmpty
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: p.stats.entries
                                  .map((e) => _buildStat(e.value, e.key))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isLoadingPages)
                            const Center(child: CircularProgressIndicator())
                          else if (pages.isNotEmpty)
                            _buildPageSelector()
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No Facebook Pages found. You need to be an admin of a Facebook Page to use analytics.',
                                      style: TextStyle(color: Colors.orange.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 30),

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool showRefresh}) {
    return Container(
      color: const Color(0xff1877F2),
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
            'Facebook',
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
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Facebook Page',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose which page to use for posting and analytics',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ...pages.map((page) {
            final isSelected = page['id'] == selectedPageId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: isSelected ? const Color(0xff1877F2) : Colors.grey.shade200,
                child: Icon(
                  Icons.facebook,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              title: Text(page['name'] ?? 'Unknown Page'),
              subtitle: Text(page['category'] ?? 'Page'),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xff1877F2))
                  : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              onTap: () => _selectPage(page['id']),
            );
          }).toList(),
        ],
      ),
    );
  }
}