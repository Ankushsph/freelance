import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import '../constants/auth_keys.dart';
import '../models/post.dart';
import '../models/trending_post.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user');
    }

    final data = jsonDecode(response.body);

    await prefs.setString(
      AuthKeys.userMe,
      jsonEncode(data),
    );

    return data;
  }

  static Future<Map<String, String>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        'token': data['token'],
        'name': data['user']['name'],
        'email': data['user']['email'],
      };
    } else {
      throw Exception('Login failed');
    }
  }

  static Future<Map<String, String>> createUser({
    required String name,
    required String email,
    required int number,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'number': number,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return {
        'token': data['token'],
        'name': data['user']['name'],
        'email': data['user']['email'],
      };
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Signup failed';
      throw Exception(error);
    }
  }

  static Future<void> saveAuthData(String token, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthKeys.token, token);
    await prefs.setString(AuthKeys.userName, name);
    await prefs.setString(AuthKeys.userEmail, email);
  }

  static Future<void> sendOtp({
    required String email,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'purpose': purpose}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
  }

  static Future<void> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'purpose': purpose}),
    );
    if (response.statusCode != 200) {
      throw Exception('Invalid OTP');
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (res.statusCode != 200) {
      throw Exception('Password reset failed');
    }
  }

  static Future<Map<String, dynamic>> getInstagramProfile({required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/instagram/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Instagram not connected');
    }

    final data = jsonDecode(response.body);
    
    final profileData = data['profile'] ?? data;

    await prefs.setString(
      AuthKeys.instagramProfile,
      jsonEncode(profileData),
    );

    return profileData;
  }

  static Future<void> publishToInstagram({
    required String token,
    required String imageUrl,
    String? caption,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/instagram/publish'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageUrl': imageUrl, 'caption': caption ?? ''}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to publish to Instagram: ${response.body}');
    }
  }

  static Future<String> uploadFile(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload file');
    }

    final data = jsonDecode(response.body);
    return data['url'];
  }

  static Future<Map<String, dynamic>> getFacebookProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/facebook/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Facebook not connected');
    }

    final data = jsonDecode(response.body);
    
    final profileData = data['profile'] ?? data;

    await prefs.setString(
      AuthKeys.facebookProfile,
      jsonEncode(profileData),
    );

    return profileData;
  }

  static Future<Map<String, dynamic>> getLinkedInProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/linkedin/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('LinkedIn not connected');
    }

    final data = jsonDecode(response.body);
    
    final profileData = data['profile'] ?? data;

    await prefs.setString(
      AuthKeys.linkedinProfile,
      jsonEncode(profileData),
    );

    return profileData;
  }

  static Future<Map<String, dynamic>> getTwitterProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/twitter/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Twitter not connected');
    }

    final data = jsonDecode(response.body);
    
    final profileData = data['profile'] ?? data;

    await prefs.setString(
      AuthKeys.twitterProfile,
      jsonEncode(profileData),
    );

    return profileData;
  }

  static Future<void> disconnectLinkedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/disconnect/linkedin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to disconnect LinkedIn');
    }
  }

  static Future<void> disconnectTwitter() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/disconnect/twitter'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to disconnect Twitter');
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String content,
    required List<String> platforms,
    required File media,
    String? tags,
    String? scheduledTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['content'] = content;
    request.fields['platforms'] = platforms.join(',');
    if (tags != null && tags.isNotEmpty) {
      request.fields['tags'] = tags;
    }
    request.fields['scheduledTime'] = scheduledTime ?? 'now';

    final mimeType = lookupMimeType(media.path) ?? 'image/jpeg';
    final fileExtension = media.path.split('.').last.toLowerCase();
    
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!allowedExtensions.contains(fileExtension)) {
      throw Exception('Only image files are allowed (jpg, jpeg, png, gif, webp). Got: $fileExtension');
    }
    
    request.files.add(await http.MultipartFile.fromPath(
      'media', 
      media.path,
      contentType: MediaType.parse(mimeType),
      filename: 'image.$fileExtension',
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMessage;
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] ?? 'Failed to create post (Status: ${response.statusCode})';
      } catch (e) {
        errorMessage = 'Server error (Status: ${response.statusCode}). Please check server logs.';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<List<Post>> getUserPosts({int limit = 100, int skip = 0, String? platform}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    String url = '$baseUrl/posts?limit=$limit&skip=$skip';
    if (platform != null && platform.isNotEmpty) {
      url += '&platform=$platform';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final postsData = data['posts'] as List<dynamic>? ?? [];
      return postsData.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  static Future<void> disconnectInstagram() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/disconnect/instagram'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to disconnect Instagram');
    }
  }

  static Future<void> disconnectFacebook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/disconnect/facebook'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to disconnect Facebook');
    }
  }

  static Future<String> generateCaption({
    required String message,
    String? platform,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/ai/generate-caption'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
        'platform': platform,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['caption'] ?? 'No caption generated';
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to generate caption');
    }
  }

  static Future<List<String>> generateHashtags({
    required String caption,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/ai/generate-hashtags'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'caption': caption,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['hashtags'] ?? []);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to generate hashtags');
    }
  }

  static Future<Map<String, dynamic>> getAnalytics({
    required String platform,
    int days = 30,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/analytics/$platform?days=$days'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch analytics');
    }
  }

  static Future<Map<String, dynamic>> getPostAnalytics({
    required String platform,
    required String postId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/analytics/$platform/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch post analytics');
    }
  }

  static Future<List<Post>> getScheduledPostsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/posts?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final postsData = data['posts'] as List<dynamic>? ?? [];
      return postsData.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch scheduled posts');
    }
  }

  static Future<void> cancelScheduledPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to cancel scheduled post');
    }
  }

  static Future<Map<String, dynamic>> getTrendingPosts({
    int limit = 20,
    int skip = 0,
    String platform = 'all',
    String timeframe = '7d',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trending?limit=$limit&skip=$skip&platform=$platform&timeframe=$timeframe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final postsData = data['data']?['posts'] as List<dynamic>? ?? [];
      final posts = postsData.map((json) {
        return TrendingPost.fromJson(json as Map<String, dynamic>);
      }).toList();
      return {
        'posts': posts,
        'pagination': data['data']?['pagination'] ?? {},
      };
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch trending posts');
    }
  }

  static Future<List<TrendingPost>> getUserTrendingPosts({
    int limit = 20,
    int skip = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trending/me?limit=$limit&skip=$skip'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final postsData = data['data']?['posts'] as List<dynamic>? ?? [];
      return postsData.map((json) => TrendingPost.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch user trending posts');
    }
  }

  static Future<TrendingStats> getTrendingStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/trending/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TrendingStats.fromJson(data['data'] ?? {});
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch trending stats');
    }
  }

  static Future<Map<String, dynamic>> populateTrendingPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);

    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/trending/populate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to populate trending posts');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBoosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.token);
    final userData = prefs.getString(AuthKeys.userMe);

    if (token == null) {
      throw Exception('User not logged in');
    }

    String? userId;
    if (userData != null) {
      final user = jsonDecode(userData);
      userId = user['id'] ?? user['_id'];
    }

    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/boost/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch boost history');
    }
  }

}