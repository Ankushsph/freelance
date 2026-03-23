import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool popupNotification = true;
  bool pushNotification = true;
  bool scheduleReminder = true;
  bool algorithmTime = true;
  bool emailNotification = true;
  bool smsNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      popupNotification = prefs.getBool('popupNotification') ?? true;
      pushNotification = prefs.getBool('pushNotification') ?? true;
      scheduleReminder = prefs.getBool('scheduleReminder') ?? true;
      algorithmTime = prefs.getBool('algorithmTime') ?? true;
      emailNotification = prefs.getBool('emailNotification') ?? true;
      smsNotification = prefs.getBool('smsNotification') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popupNotification', popupNotification);
    await prefs.setBool('pushNotification', pushNotification);
    await prefs.setBool('scheduleReminder', scheduleReminder);
    await prefs.setBool('algorithmTime', algorithmTime);
    await prefs.setBool('emailNotification', emailNotification);
    await prefs.setBool('smsNotification', smsNotification);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved')),
      );
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
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSettingTile(
                  'Pop up notification',
                  popupNotification,
                  (value) => setState(() => popupNotification = value),
                ),
                _buildSettingTile(
                  'Push notification',
                  pushNotification,
                  (value) => setState(() => pushNotification = value),
                ),
                _buildSettingTile(
                  'Schedule reminder',
                  scheduleReminder,
                  (value) => setState(() => scheduleReminder = value),
                ),
                _buildSettingTile(
                  'Algorithm time',
                  algorithmTime,
                  (value) => setState(() => algorithmTime = value),
                ),
                _buildSettingTile(
                  'Email notification',
                  emailNotification,
                  (value) => setState(() => emailNotification = value),
                ),
                _buildSettingTile(
                  'SMS notification',
                  smsNotification,
                  (value) => setState(() => smsNotification = value),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DA1F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1DA1F2),
          ),
        ],
      ),
    );
  }
}
