import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/auth_keys.dart';

class AuthStorage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthKeys.token, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthKeys.token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.token);
  }

  static Future<void> saveInstagramProfile(
      Map<String, dynamic> profile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AuthKeys.instagramProfile,
      jsonEncode(profile),
    );
  }

  static Future<Map<String, dynamic>?> getStoredInstagramProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthKeys.instagramProfile);

    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        await prefs.remove(AuthKeys.instagramProfile);
        return null;
      }
    } catch (e) {
      await prefs.remove(AuthKeys.instagramProfile);
      return null;
    }
  }

  static Future<void> clearInstagramProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.instagramProfile);
    print('Instagram profile removed');
  }

  static Future<void> saveFacebookProfile(
      Map<String, dynamic> profile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AuthKeys.facebookProfile,
      jsonEncode(profile),
    );
  }

  static Future<Map<String, dynamic>?> getStoredFacebookProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthKeys.facebookProfile);

    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        await prefs.remove(AuthKeys.facebookProfile);
        return null;
      }
    } catch (_) {
      await prefs.remove(AuthKeys.facebookProfile);
      return null;
    }
  }

  static Future<void> clearFacebookProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.facebookProfile);
  }

  static Future<void> saveLinkedInProfile(
      Map<String, dynamic> profile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AuthKeys.linkedinProfile,
      jsonEncode(profile),
    );
  }

  static Future<Map<String, dynamic>?> getStoredLinkedInProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthKeys.linkedinProfile);

    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        await prefs.remove(AuthKeys.linkedinProfile);
        return null;
      }
    } catch (_) {
      await prefs.remove(AuthKeys.linkedinProfile);
      return null;
    }
  }

  static Future<void> clearLinkedInProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.linkedinProfile);
    print('LinkedIn profile removed');
  }

  static Future<void> saveTwitterProfile(
      Map<String, dynamic> profile,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AuthKeys.twitterProfile,
      jsonEncode(profile),
    );
  }

  static Future<Map<String, dynamic>?> getStoredTwitterProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthKeys.twitterProfile);

    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        await prefs.remove(AuthKeys.twitterProfile);
        return null;
      }
    } catch (_) {
      await prefs.remove(AuthKeys.twitterProfile);
      return null;
    }
  }

  static Future<void> clearTwitterProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.twitterProfile);
    print('Twitter profile removed');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthKeys.token);
    await prefs.remove(AuthKeys.userMe);
    await prefs.remove(AuthKeys.instagramProfile);
    await prefs.remove(AuthKeys.facebookProfile);
    await prefs.remove(AuthKeys.linkedinProfile);
    await prefs.remove(AuthKeys.twitterProfile);
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_profile_image');
    await prefs.remove('post_notification');
    print('All auth data cleared');
  }
}