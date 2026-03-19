import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../../services/api_service.dart';

class TwitterPostScreen extends StatefulWidget {
  final DateTime? preSelectedDate;

  const TwitterPostScreen({super.key, this.preSelectedDate});

  @override
  State<TwitterPostScreen> createState() => _TwitterPostScreenState();
}

class _TwitterPostScreenState extends State<TwitterPostScreen> {
  final captionController = TextEditingController();

  File? media;

  bool isGeneratingCaption = false;
  String? lastGeneratedCaption;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedDate != null) {
      final now = DateTime.now();
      final preSelected = widget.preSelectedDate!;

      if (preSelected.isAfter(now)) {
        setState(() {
          postNow = false;
          scheduledDate = DateTime(preSelected.year, preSelected.month, preSelected.day);
          final nextHour = now.add(const Duration(hours: 1));
          if (preSelected.day == now.day && preSelected.month == now.month && preSelected.year == now.year) {
            scheduledTime = TimeOfDay(hour: nextHour.hour, minute: nextHour.minute);
          } else {
            scheduledTime = const TimeOfDay(hour: 9, minute: 0);
          }
        });
      }
    }
  }

  Future<void> _generateAICaption() async {
    final userMessage = captionController.text.trim();
    if (userMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write something first to generate a caption"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isGeneratingCaption = true);

    try {
      final caption = await ApiService.generateCaption(
        message: userMessage,
        platform: 'Twitter',
      );

      if (mounted) {
        setState(() {
          lastGeneratedCaption = caption;
          captionController.text = caption;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI caption generated!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate caption: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGeneratingCaption = false);
      }
    }
  }

  Future<void> _regenerateCaption() async {
    if (lastGeneratedCaption == null || !mounted) return;
    setState(() {
      captionController.text = lastGeneratedCaption!;
    });
    await _generateAICaption();
  }

  Widget _buildAIButton() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastGeneratedCaption != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: isGeneratingCaption ? null : _regenerateCaption,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isGeneratingCaption
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.refresh, size: 18, color: Colors.grey.shade700),
                ),
              ),
            ),
          InkWell(
            onTap: isGeneratingCaption ? null : _generateAICaption,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A5AE0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isGeneratingCaption
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_fix_high, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickMedia() async {
    final picker = ImagePicker();

    final mediaType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Media Type'),
        content: const Text('What would you like to upload?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'image'),
            child: const Text('Image'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Video'),
          ),
        ],
      ),
    );

    if (mediaType == null) return;

    XFile? file;
    if (mediaType == 'image') {
      file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    }

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

  bool isPosting = false;

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

    final platforms = ['twitter'];
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

  bool postNow = true;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/images/social/x.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text("X Post"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: pickMedia,
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade400),
                      image: media != null ? DecorationImage(image: FileImage(media!), fit: BoxFit.cover) : null,
                    ),
                    child: media == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate, size: 30, color: Colors.grey),
                              SizedBox(height: 4),
                              Text("Add Media", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: captionController,
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: captionController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "Write a tweet...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (value.text.isNotEmpty) Align(alignment: Alignment.bottomRight, child: _buildAIButton()),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Post Schedule", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          value: true,
                          groupValue: postNow,
                          activeColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Post Now"),
                          onChanged: (v) => setState(() {
                            postNow = true;
                            scheduledDate = null;
                            scheduledTime = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          value: false,
                          groupValue: postNow,
                          activeColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Schedule"),
                          onChanged: (v) => setState(() => postNow = false),
                        ),
                      ),
                    ],
                  ),
                  if (!postNow) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: pickSchedule,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black),
                          color: Colors.black.withOpacity(.05),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.black),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                scheduledDate == null
                                    ? "Select date & time"
                                    : "${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}  •  ${scheduledTime!.format(context)}",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isPosting ? null : postContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(postNow ? "Post Now" : "Schedule Post"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  media = null;
                  captionController.clear();
                });
              },
              child: const Text(
                "Save as Draft",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}