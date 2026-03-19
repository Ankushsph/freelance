import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../../services/api_service.dart';

class DemoAccount {
  final String name;
  final String logo;

  DemoAccount(this.name, this.logo);
}

class PostScreen extends StatefulWidget {
  final DateTime? preSelectedDate;
  final List<String>? preSelectedPlatforms;

  const PostScreen({super.key, this.preSelectedDate, this.preSelectedPlatforms});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final List<DemoAccount> accounts = [
    DemoAccount("IG", "assets/images/social/ig.png"),
    DemoAccount("FB", "assets/images/social/fb.png"),
    DemoAccount("X", "assets/images/social/x.png"),
    DemoAccount("LI", "assets/images/social/linkedin.png"),
  ];

  late Set<String> selectedPlatforms;

  final captionController = TextEditingController();
  final tagController = TextEditingController();
  final topicController = TextEditingController();
  final locationController = TextEditingController();

  File? media;

  bool hideLikes = false;
  bool turnOffComments = false;
  bool showCaptions = true;

  @override
  void initState() {
    super.initState();
    selectedPlatforms = {};
    
    if (widget.preSelectedPlatforms != null) {
      selectedPlatforms.addAll(widget.preSelectedPlatforms!);
    }
    
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

  bool isGeneratingCaption = false;
  String? lastGeneratedCaption;

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
      String? platform;
      if (selectedPlatforms.contains('ig')) platform = 'Instagram';
      else if (selectedPlatforms.contains('fb')) platform = 'Facebook';
      else if (selectedPlatforms.contains('x')) platform = 'Twitter';
      else if (selectedPlatforms.contains('li')) platform = 'LinkedIn';

      final caption = await ApiService.generateCaption(
        message: userMessage,
        platform: platform,
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

  void _showVideoUnderDevelopmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text(''),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video posting is needs to verify the app on platforms.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Please use image uploads for now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
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
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
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
            onPressed: () {
              Navigator.pop(context);
              _showVideoUnderDevelopmentDialog();
            },
            child: const Text('Video'),
          ),
        ],
      ),
    );

    if (mediaType == null) return;

    XFile? file;
    if (mediaType == 'image') {
      file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } else {
      file = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
    }

    if (file == null) return;

    final filePath = file.path;
    final extension = path.extension(filePath).toLowerCase().replaceFirst('.', '');

    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'heic', 'heif'];
    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'm4v', '3gp'];

    final allExtensions = [...imageExtensions, ...videoExtensions];

    if (!allExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unsupported file format: .$extension\nSupported: jpg, png, gif, webp, mp4, mov, etc.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final fileSize = await File(filePath).length();
    final maxSize = mediaType == 'image' ? 50 * 1024 * 1024 : 100 * 1024 * 1024;

    if (fileSize > maxSize) {
      final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      final maxMB = mediaType == 'image' ? '50MB' : '100MB';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File too large: ${sizeMB}MB (max $maxMB)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => media = File(filePath));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${mediaType == 'image' ? 'Image' : 'Video'} selected (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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

    if (selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one platform")),
      );
      return;
    }

    final platforms = selectedPlatforms.map((p) {
      switch (p) {
        case 'ig':
          return 'instagram';
        case 'fb':
          return 'facebook';
        case 'x':
          return 'twitter';
        case 'li':
          return 'linkedin';
        default:
          return p;
      }
    }).toList();

    final caption = captionController.text.trim();
    final tags = tagController.text.trim();
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

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );

    _postInBackground(
      caption: caption,
      platforms: platforms,
      media: mediaFile,
      tags: tags.isNotEmpty ? tags : null,
      scheduledTime: scheduledTimeStr,
      isScheduled: isScheduled,
    );
  }

  void _postInBackground({
    required String caption,
    required List<String> platforms,
    required File media,
    String? tags,
    String? scheduledTime,
    required bool isScheduled,
  }) async {
    try {
      final result = await ApiService.createPost(
        content: caption,
        platforms: platforms,
        media: media,
        tags: tags,
        scheduledTime: scheduledTime,
      );

      final prefs = await SharedPreferences.getInstance();
      final message = isScheduled
          ? "Post scheduled successfully!"
          : "Post created and publishing...";

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

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (selected.isBefore(minScheduleTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a time at least 5 minutes from now (${minScheduleTime.hour}:${minScheduleTime.minute.toString().padLeft(2, '0')})"),
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

  Widget buildToggle(String title, bool value, Function(bool) onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFF2563EB),
        title: Text(title),
        value: value,
        onChanged: onChange,
      ),
    );
  }

  Widget buildPlatformButton(DemoAccount acc) {
    final key = acc.name.toLowerCase();
    final selected = selectedPlatforms.contains(key);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected ? selectedPlatforms.remove(key) : selectedPlatforms.add(key);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF2563EB).withOpacity(.7)])
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Color(0xFF2563EB) : Colors.grey.shade300),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(acc.logo, width: 28, height: 28),
              const SizedBox(height: 6),
              Text(
                acc.name,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInput(String hint, IconData icon, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Create Post"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload to",
              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              children: accounts.map(buildPlatformButton).toList(),
            ),
            const SizedBox(height: 20),
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
                                  hintText: "Write a caption...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (value.text.isNotEmpty)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: _buildAIButton(),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildInput("Tags", Icons.person, tagController),
            buildInput("Topics / Hashtags", Icons.tag, topicController),
            buildToggle("Hide likes and plays", hideLikes, (v) => setState(() => hideLikes = v)),
            buildToggle("Turn off comments", turnOffComments, (v) => setState(() => turnOffComments = v)),
            buildToggle("Show captions", showCaptions, (v) => setState(() => showCaptions = v)),
            const SizedBox(height: 6),
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
                          activeColor: const Color(0xFF2563EB),
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
                          activeColor: const Color(0xFF2563EB),
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
                          border: Border.all(color: const Color(0xFF2563EB)),
                          color: const Color(0xFF2563EB).withOpacity(.05),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                scheduledDate == null
                                    ? "Select date & time"
                                    : "${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}  •  ${scheduledTime!.format(context)}",
                                style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        media = null;
                        captionController.clear();
                        selectedPlatforms.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Save as Draft"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isPosting ? null : postContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: const Color(0xFFF4F6FA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        : const Text("Post"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}