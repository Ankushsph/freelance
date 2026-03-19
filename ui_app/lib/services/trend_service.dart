import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trend_model.dart';

class TrendService {
  static const String baseUrl = 'http://localhost:4000/api/trends';

  // Fetch popular trends
  static Future<List<Trend>> getPopularTrends({
    required String platform,
    String category = 'reels',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/popular?platform=$platform&category=$category'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          return data.map((item) => Trend.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching popular trends: $e');
      return [];
    }
  }

  // Fetch personalized trends (For You)
  static Future<List<Trend>> getForYouTrends({
    required String platform,
    required String userId,
    String category = 'reels',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/for-you?platform=$platform&userId=$userId&category=$category'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          return data.map((item) => Trend.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching for-you trends: $e');
      return [];
    }
  }

  // Fetch saved trends
  static Future<List<Trend>> getSavedTrends({
    required String userId,
    required String platform,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saved?userId=$userId&platform=$platform'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          return data.map((item) => Trend.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching saved trends: $e');
      return [];
    }
  }

  // Save a trend
  static Future<bool> saveTrend({
    required String userId,
    required String trendId,
    required String platform,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'trendId': trendId,
          'platform': platform,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error saving trend: $e');
      return false;
    }
  }

  // Unsave a trend
  static Future<bool> unsaveTrend(String savedTrendId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/unsave/$savedTrendId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error unsaving trend: $e');
      return false;
    }
  }
}
