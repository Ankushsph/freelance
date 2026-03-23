import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/auth_keys.dart';

class AccountService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> getConnectedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/connected'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch connected accounts');
    }
  }

  static Future<void> setActiveAccount(String platform) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/set-active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'platform': platform}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to set active account');
    }
  }

  static Future<String?> getActiveAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/active'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['activePlatform'];
    } else {
      throw Exception('Failed to fetch active account');
    }
  }
}
