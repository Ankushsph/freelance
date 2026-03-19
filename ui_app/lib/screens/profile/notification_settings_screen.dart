import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool postPublished = true;
  bool postFailed = true;
  bool scheduledPost = true;
  bool newFollower = false;
  bool engagement = true;
  bool marketingEmails = false;
  bool dailyDigest = true;
  bool weeklyReport = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      postPublished = prefs.getBool('notify_post_published') ?? true;
      postFailed = prefs.getBool('notify_post_failed') ?? true;
      scheduledPost = prefs.getBool('notify_scheduled_post') ?? true;
      newFollower = prefs.getBool('notify_new_follower') ?? false;
      engagement = prefs.getBool('notify_engagement') ?? true;
      marketingEmails = prefs.getBool('notify_marketing') ?? false;
      dailyDigest = prefs.getBool('notify_daily_digest') ?? true;
      weeklyReport = prefs.getBool('notify_weekly_report') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: icon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
          },
          activeColor: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('POSTS'),
            _buildSwitchTile(
              title: 'Post Published',
              subtitle: 'Get notified when your post is published',
              icon: Icons.check_circle,
              value: postPublished,
              onChanged: (value) {
                setState(() => postPublished = value);
                _saveSetting('notify_post_published', value);
              },
            ),
            _buildSwitchTile(
              title: 'Post Failed',
              subtitle: 'Get notified when a post fails to publish',
              icon: Icons.error,
              value: postFailed,
              onChanged: (value) {
                setState(() => postFailed = value);
                _saveSetting('notify_post_failed', value);
              },
            ),
            _buildSwitchTile(
              title: 'Scheduled Post',
              subtitle: 'Reminders before scheduled posts go live',
              icon: Icons.schedule,
              value: scheduledPost,
              onChanged: (value) {
                setState(() => scheduledPost = value);
                _saveSetting('notify_scheduled_post', value);
              },
            ),
            _buildSectionHeader('SOCIAL'),
            _buildSwitchTile(
              title: 'New Follower',
              subtitle: 'When someone follows your connected accounts',
              icon: Icons.person_add,
              value: newFollower,
              onChanged: (value) {
                setState(() => newFollower = value);
                _saveSetting('notify_new_follower', value);
              },
            ),
            _buildSwitchTile(
              title: 'Engagement',
              subtitle: 'Likes, comments, and shares on your posts',
              icon: Icons.favorite,
              value: engagement,
              onChanged: (value) {
                setState(() => engagement = value);
                _saveSetting('notify_engagement', value);
              },
            ),
            _buildSectionHeader('EMAIL'),
            _buildSwitchTile(
              title: 'Marketing Emails',
              subtitle: 'Tips, new features, and promotional offers',
              icon: Icons.mail,
              value: marketingEmails,
              onChanged: (value) {
                setState(() => marketingEmails = value);
                _saveSetting('notify_marketing', value);
              },
            ),
            _buildSwitchTile(
              title: 'Daily Digest',
              subtitle: 'Summary of your daily posting activity',
              icon: Icons.today,
              value: dailyDigest,
              onChanged: (value) {
                setState(() => dailyDigest = value);
                _saveSetting('notify_daily_digest', value);
              },
            ),
            _buildSwitchTile(
              title: 'Weekly Report',
              subtitle: 'Analytics and insights for the week',
              icon: Icons.assessment,
              value: weeklyReport,
              onChanged: (value) {
                setState(() => weeklyReport = value);
                _saveSetting('notify_weekly_report', value);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}