import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/auth_keys.dart';
import '../models/subscription.dart';

class SubscriptionService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Subscription?> getMySubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthKeys.token);

      if (token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/subscription/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Subscription.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch subscription');
      }
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> createOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthKeys.token);

      if (token == null) {
        throw Exception('User not logged in');
      }

      print('Creating order with token: ${token.substring(0, 20)}...');
      print('API URL: $baseUrl/subscription/create-order');

      final response = await http.post(
        Uri.parse('$baseUrl/subscription/create-order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          final errorMsg = data['message'] ?? 'Invalid response format';
          final errorDetail = data['error'] ?? '';
          throw Exception('$errorMsg${errorDetail.isNotEmpty ? ': $errorDetail' : ''}');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['message'] ?? 'Failed to create order';
          final errorDetail = errorData['error'] ?? '';
          throw Exception('$errorMsg${errorDetail.isNotEmpty ? ': $errorDetail' : ''}');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  static Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthKeys.token);

      if (token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/subscription/verify-payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'razorpayOrderId': orderId,
          'razorpayPaymentId': paymentId,
          'razorpaySignature': signature,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  static Future<bool> cancelSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthKeys.token);

      if (token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/subscription/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  static Future<bool> checkFeatureAccess(String feature) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthKeys.token);

      if (token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/subscription/check-feature/$feature'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasAccess'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking feature access: $e');
      return false;
    }
  }
}
