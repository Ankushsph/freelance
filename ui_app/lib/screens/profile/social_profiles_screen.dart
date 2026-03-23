import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../social/instagram_profile_screen.dart';
import '../social/facebook_profile_screen.dart';
import '../social/linkedin_profile_screen.dart';
import '../social/twitter_profile_screen.dart';

class SocialProfilesScreen extends StatefulWidget {
  const SocialProfilesScreen({super.key});

  @override
  State<SocialProfilesScreen> createState() => _SocialProfilesScreenState();
}

class _SocialProfilesScreenState extends State<SocialProfilesScreen> {
  String selectedPlatform = 'instagram';
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlatformData();
  }

  Future<void> _loadPlatformData() async {
    setState(() => isLoading = true);
    
    try {
      final userData = await ApiService.getMe();
      
      switch (selectedPlatform) {
        case 'instagram':
          _usernameController.text = userData['instagramUsername'] ?? '';
          break;
        case 'facebook':
          _usernameController.text = userData['facebookUsername'] ?? '';
          break;
        case 'linkedin':
          _usernameController.text = userData['linkedinUsername'] ?? '';
          break;
        case 'twitter':
          _usernameController.text = userData['twitterUsername'] ?? '';
          break;
      }
      
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Account'),
        content: Text('Are you sure you want to remove your ${_getPlatformName()} account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1DA1F2)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.disconnectSocialAccount(selectedPlatform);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_getPlatformName()} account removed')),
          );
          _usernameController.clear();
          _passwordController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _connectAccount() async {
    Widget? targetScreen;
    
    switch (selectedPlatform) {
      case 'instagram':
        targetScreen = const InstagramProfileScreen();
        break;
      case 'facebook':
        targetScreen = const FacebookProfileScreen();
        break;
      case 'linkedin':
        targetScreen = const LinkedInProfileScreen();
        break;
      case 'twitter':
        targetScreen = const TwitterProfileScreen();
        break;
    }

    if (targetScreen != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
      
      // Reload data after returning from OAuth screen
      _loadPlatformData();
    }
  }

  String _getPlatformName() {
    switch (selectedPlatform) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'linkedin':
        return 'LinkedIn';
      case 'twitter':
        return 'X';
      default:
        return '';
    }
  }

  Color _getPlatformColor() {
    switch (selectedPlatform) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'twitter':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Social Profiles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlatformTabs(),
              const SizedBox(height: 32),
              const Text(
                'User name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: _removeAccount,
                  icon: const Icon(Icons.logout, color: Color(0xFF1DA1F2)),
                  label: const Text(
                    'Remove Account',
                    style: TextStyle(
                      color: Color(0xFF1DA1F2),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _connectAccount,
                  icon: const Icon(Icons.link, color: Colors.white),
                  label: Text(
                    'Connect ${_getPlatformName()} Account',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPlatformColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformTabs() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlatformTab('instagram', _buildInstagramIcon),
          _buildPlatformTab('facebook', _buildFacebookIcon),
          _buildPlatformTab('linkedin', _buildLinkedInIcon),
          _buildPlatformTab('twitter', _buildXIcon),
        ],
      ),
    );
  }

  Widget _buildPlatformTab(String platform, Widget Function(bool, Color) iconBuilder) {
    final isSelected = selectedPlatform == platform;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlatform = platform;
          _passwordController.clear();
        });
        _loadPlatformData();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconBuilder(isSelected, isSelected ? _getPlatformColor() : Colors.white),
        ),
      ),
    );
  }

  Widget _buildInstagramIcon(bool isSelected, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xffFEDA75),
                  Color(0xffFA7E1E),
                  Color(0xffD62976),
                  Color(0xff962FBF),
                  Color(0xff4F5BD5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.camera_alt_rounded,
        color: isSelected ? Colors.white : color,
        size: 20,
      ),
    );
  }

  Widget _buildFacebookIcon(bool isSelected, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1877F2) : color,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedInIcon(bool isSelected, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0A66C2) : color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildXIcon(bool isSelected, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : color,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '𝕏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
