import 'package:shared_preferences/shared_preferences.dart';

class SocialConnectionService {
  static const _igKey = 'instagram_connected';

  static Future<bool> isInstagramConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_igKey) ?? false;
  }

  static Future<void> setInstagramConnected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_igKey, value);
  }

  static const _fbKey = 'fafcebook_connected';

  static Future<bool> isFacebookConnected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fbKey) ?? false;
  }

  static Future<void> setFacebookConnected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fbKey, value);
  }
}