import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformProvider extends ChangeNotifier {
  static const String _storageKey = 'selected_platform';
  
  String _selectedPlatform = 'IG';
  bool _isInitialized = false;

  String get selectedPlatform => _selectedPlatform;
  bool get isInitialized => _isInitialized;

  PlatformConfig get currentConfig {
    return platforms.firstWhere(
      (p) => p.id == _selectedPlatform,
      orElse: () => platforms.first,
    );
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null && platforms.any((p) => p.id == stored)) {
      _selectedPlatform = stored;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSelectedPlatform(String platformId) async {
    if (!platforms.any((p) => p.id == platformId)) return;
    
    _selectedPlatform = platformId;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, platformId);
    
    notifyListeners();
  }

  String getPlatformName(String platformId) {
    return platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => platforms.first,
    ).name;
  }

  String getPlatformApiName(String platformId) {
    return platforms.firstWhere(
      (p) => p.id == platformId,
      orElse: () => platforms.first,
    ).apiName;
  }
}

class PlatformConfig {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String apiName;
  final String iconPath;

  const PlatformConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.apiName,
    required this.iconPath,
  });
}

const platforms = [
  PlatformConfig(
    id: 'IG',
    name: 'Instagram',
    icon: Icons.camera_alt,
    color: Color(0xFFE4405F),
    apiName: 'instagram',
    iconPath: 'assets/images/social/ig.png',
  ),
  PlatformConfig(
    id: 'FB',
    name: 'Facebook',
    icon: Icons.facebook,
    color: Color(0xFF1877F2),
    apiName: 'facebook',
    iconPath: 'assets/images/social/fb.png',
  ),
  PlatformConfig(
    id: 'X',
    name: 'X (Twitter)',
    icon: Icons.flutter_dash,
    color: Color(0xFF000000),
    apiName: 'twitter',
    iconPath: 'assets/images/social/x.png',
  ),
  PlatformConfig(
    id: 'LN',
    name: 'LinkedIn',
    icon: Icons.business,
    color: Color(0xFF0A66C2),
    apiName: 'linkedin',
    iconPath: 'assets/images/social/linkedin.png',
  ),
];

PlatformConfig getPlatformConfig(String platformId) {
  return platforms.firstWhere(
    (p) => p.id == platformId,
    orElse: () => platforms.first,
  );
}