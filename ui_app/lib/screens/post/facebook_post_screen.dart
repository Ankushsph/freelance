import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/account_service.dart';

class FacebookPostScreen extends StatefulWidget {
  final DateTime? preSelectedDate;

  const FacebookPostScreen({super.key, this.preSelectedDate});

  @override
  State<FacebookPostScreen> createState() => _FacebookPostScreenState();
}

class _FacebookPostScreenState extends State<FacebookPostScreen> {
  final captionController = TextEditingController();
  File? media;
  bool isPosting = false;
  bool postNow = true;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool instagramSharingOff = true;
  
  Map<String, dynamic>? facebookAccount;
  bool isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadFacebookAccount();
    
    if (widget.preSelectedDate != null) {
      final now = DateTime.now();
      final preSelected = widget.preSelectedDate!;

      if (preSelected.isAfter(now)) {
        postNow = false;
        scheduledDate = DateTime(preSelected.year, preSelected.month, preSelected.day);
        final nextHour = now.add(const Duration(hours: 1));
        if (preSelected.day == now.day && preSelected.month == now.month && preSelected.year == now.year) {
          scheduledTime = TimeOfDay(hour: nextHour.hour, minute: nextHour.minute);
        } else {
          scheduledTime = const TimeOfDay(hour: 9, minute: 0);
        }
      }
    }
  }

  Future<void> _loadFacebookAccount() async {
    try {
      final data = await AccountService.getConnectedAccounts();
      final accounts = List<Map<String, dynamic>>.from(data['accounts'] ?? []);
      final facebook = accounts.firstWhere(
        (acc) => acc['platform'] == 'facebook',
        orElse: () => {},
      );
      
      setState(() {
        facebookAccount = facebook.isNotEmpty ? facebook : null;
        isLoadingAccount = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAccount = false;
      });
    }
  }

  Future<void> pickMedia() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (file == null) return;

    final filePath = file.path;
    final extension = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'heic', 'heif'];

    if (!imageExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unsupported file format: .$extension'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fileSize = await File(filePath).length();
    if (fileSize > 50 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File too large (max 50MB)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => media = File(filePath));
  }

  Future<void> postContent() async {
    if (isPosting) return;

    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    if (media == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select media to post")),
      );
      return;
    }

    final platforms = ['facebook'];
    final caption = captionController.text.trim();
    final mediaFile = media!;
    final isScheduled = !postNow && scheduledDate != null && scheduledTime != null;

    String? scheduledTimeStr;
    if (isScheduled) {
      final dateTime = DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        scheduledTime!.hour,
        scheduledTime!.minute,
      );
      scheduledTimeStr = dateTime.toIso8601String();
    }

    prefs.setString('post_notification', jsonEncode({
      'type': 'success',
      'message': isScheduled ? 'Scheduling post...' : 'Posting...',
      'timestamp': DateTime.now().toIso8601String(),
      'pending': true,
    }));

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    _postInBackground(
      caption: caption,
      platforms: platforms,
      media: mediaFile,
      scheduledTime: scheduledTimeStr,
      isScheduled: isScheduled,
    );
  }

  void _postInBackground({
    required String caption,
    required List<String> platforms,
    required File media,
    String? scheduledTime,
    required bool isScheduled,
  }) async {
    try {
      await ApiService.createPost(
        content: caption,
        platforms: platforms,
        media: media,
        scheduledTime: scheduledTime,
      );

      final prefs = await SharedPreferences.getInstance();
      final message = isScheduled ? "Post scheduled successfully!" : "Post created and publishing...";

      await prefs.setString('post_notification', jsonEncode({
        'type': 'success',
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('FormatException')) {
        errorMsg = 'Server error: The API endpoint may not be available.';
      } else if (errorMsg.length > 100) {
        errorMsg = errorMsg.substring(0, 100) + '...';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('post_notification', jsonEncode({
        'type': 'error',
        'message': errorMsg,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }

  Future<void> pickSchedule() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return;

    final minScheduleTime = now.add(const Duration(minutes: 5));
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    TimeOfDay initialTime;
    if (isToday) {
      initialTime = TimeOfDay.fromDateTime(minScheduleTime);
    } else {
      initialTime = const TimeOfDay(hour: 9, minute: 0);
    }

    final time = await showTimePicker(context: context, initialTime: initialTime);

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (selected.isBefore(minScheduleTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a time at least 5 minutes from now"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      scheduledDate = date;
      scheduledTime = time;
      postNow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = captionController.text.trim().isNotEmpty || media != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create post',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: (hasContent && !isPosting) ? postContent : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasContent
                    ? const Color(0xFF1877F2)
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
              ),
              child: const Text(
                'POST',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: facebookAccount != null &&
                                facebookAccount!['avatar'] != null &&
                                facebookAccount!['avatar'].toString().isNotEmpty
                            ? NetworkImage(facebookAccount!['avatar'])
                            : null,
                        child: facebookAccount == null ||
                                facebookAccount!['avatar'] == null ||
                                facebookAccount!['avatar'].toString().isEmpty
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        facebookAccount?['username'] ?? 'Facebook User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dropdowns row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 16, color: Color(0xFF1877F2)),
                            const SizedBox(width: 4),
                            const Text(
                              'Friends',
                              style: TextStyle(fontSize: 13, color: Color(0xFF1877F2)),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 16, color: Color(0xFF1877F2)),
                            const SizedBox(width: 4),
                            const Text(
                              'Album',
                              style: TextStyle(fontSize: 13, color: Color(0xFF1877F2)),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Instagram sharing toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F3FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt, size: 16, color: Color(0xFF1877F2)),
                        const SizedBox(width: 4),
                        Text(
                          instagramSharingOff ? 'Off' : 'On',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1877F2)),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Text area
                  TextField(
                    controller: captionController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Say something about this photo....',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  // Image preview
                  if (media != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            media!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: pickMedia,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.edit, size: 14),
                                  SizedBox(width: 4),
                                  Text('Edit', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 70,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.threed_rotation, size: 14),
                                SizedBox(width: 4),
                                Text('Make 3D', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 48,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.more_horiz, size: 16),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => media = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Bottom toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ToolbarButton(
                  icon: Icons.image_outlined,
                  color: Colors.green,
                  onTap: pickMedia,
                ),
                _ToolbarButton(
                  icon: Icons.person_add_outlined,
                  color: Colors.blue,
                  onTap: () {},
                ),
                _ToolbarButton(
                  icon: Icons.sentiment_satisfied_outlined,
                  color: Colors.orange,
                  onTap: () {},
                ),
                _ToolbarButton(
                  icon: Icons.location_on_outlined,
                  color: Colors.red,
                  onTap: () {},
                ),
                _ToolbarButton(
                  icon: Icons.more_horiz,
                  color: Colors.grey,
                  onTap: pickSchedule,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 28, color: color),
    );
  }
}