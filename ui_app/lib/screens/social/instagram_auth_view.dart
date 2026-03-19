
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InstagramOAuthPage extends StatelessWidget {
  const InstagramOAuthPage({super.key});

  Future<void> _connectInstagram(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in first")),
      );
      return;
    }

    try {
      final res = await http.post(
        Uri.parse("https://api.codesbyjit.site/api/instagram/connect"),
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

      final launched = await launchUrl(
        oauthUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception("Could not open Instagram");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect Instagram"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Login with Instagram"),
          onPressed: () => _connectInstagram(context),
        ),
      ),
    );
  }
}