import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post.dart';
import '../../services/api_service.dart';
import 'schedule_picker_sheet.dart';

class PostCreateSheet extends StatefulWidget {
  final DateTime? preSelectedDate;
  final String? platform;
  final String? platformDisplayName;
  final Post? existingPost;
  final VoidCallback? onSaved;

  const PostCreateSheet({
    super.key,
    this.preSelectedDate,
    this.platform,
    this.platformDisplayName,
    this.existingPost,
    this.onSaved,
  });

  @override
  State<PostCreateSheet> createState() => _PostCreateSheetState();
}

class _PostCreateSheetState extends State<PostCreateSheet> {
  final _captionCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _topicsCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  File? _media;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  bool _isPosting = false;
  bool _hideLikes = false;
  bool _turnOffComments = false;
  bool _showCaptions = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      final post = widget.existingPost!;
      _captionCtrl.text = post.content;
      final scheduledAt = post.scheduledTime ?? post.createdAt;
      final now = DateTime.now();
      if (scheduledAt.isAfter(now)) {
        _scheduledDate = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
        _scheduledTime = TimeOfDay.fromDateTime(scheduledAt);
      }
    } else if (widget.preSelectedDate != null) {
      final d = widget.preSelectedDate!;
      final now = DateTime.now();
      if (d.isAfter(now)) {
        _scheduledDate = DateTime(d.year, d.month, d.day);
        final isToday =
            d.year == now.year && d.month == now.month && d.day == now.day;
        _scheduledTime = isToday
            ? TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)))
            : const TimeOfDay(hour: 9, minute: 0);
      }
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _tagsCtrl.dispose();
    _topicsCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _media = File(file.path));
  }

  Future<void> _openSchedulePicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SchedulePickerSheet(
        initialDate: _scheduledDate,
        initialTime: _scheduledTime,
        platformDisplayName: widget.platformDisplayName ?? widget.platform ?? 'Instagram',
      ),
    );
    if (result != null) {
      setState(() {
        _scheduledDate = result['date'] as DateTime;
        _scheduledTime = result['time'] as TimeOfDay;
      });
    }
  }

  Future<void> _submit() async {
    if (_isPosting) return;
    if (_captionCtrl.text.trim().isEmpty) {
      _snack('Please write a caption', Colors.orange);
      return;
    }
    // Media required only for new posts, not edits
    if (_media == null && widget.existingPost == null) {
      _snack('Please select a media file', Colors.orange);
      return;
    }

    setState(() => _isPosting = true);

    String? scheduledTimeStr;
    if (_scheduledDate != null && _scheduledTime != null) {
      final dt = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
      scheduledTimeStr = dt.toIso8601String();
    }

    final apiPlatform = (widget.platform ?? 'instagram').toLowerCase();
    const validPlatforms = ['instagram', 'facebook', 'linkedin', 'twitter'];
    final resolvedPlatform = validPlatforms.contains(apiPlatform) ? apiPlatform : 'instagram';

    try {
      if (widget.existingPost != null && _media == null) {
        // Edit without new media — delete old and recreate with same media URL
        // For now just update via delete + recreate
        await ApiService.cancelScheduledPost(widget.existingPost!.id);
      }

      if (_media != null) {
        await ApiService.createPost(
          content: _captionCtrl.text.trim(),
          platforms: [resolvedPlatform],
          media: _media!,
          tags: _tagsCtrl.text.trim().isNotEmpty ? _tagsCtrl.text.trim() : null,
          scheduledTime: scheduledTimeStr,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
        _snack(
          scheduledTimeStr != null
              ? 'Post scheduled successfully!'
              : 'Post created and publishing...',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        _snack(e.toString(), Colors.red);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String get _scheduleLabel {
    if (_scheduledDate == null || _scheduledTime == null) return '';
    return '${DateTimeHelper.dayName(_scheduledDate!)}, ${_scheduledDate!.day} @ ${_scheduledTime!.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.platformDisplayName ?? widget.platform ?? 'Instagram';
    // Capitalize first letter
    final platformTitle = displayName.isNotEmpty
        ? displayName[0].toUpperCase() + displayName.substring(1)
        : 'Instagram';
    final isScheduled = _scheduledDate != null && _scheduledTime != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (ctx, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      platformTitle,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, bottomInset + 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Media + Caption row ──────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // media picker
                          GestureDetector(
                            onTap: _pickMedia,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                                image: _media != null
                                    ? DecorationImage(
                                        image: FileImage(_media!),
                                        fit: BoxFit.cover)
                                    : (widget.existingPost != null &&
                                            widget.existingPost!.mediaUrls.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                widget.existingPost!.mediaUrls.first),
                                            fit: BoxFit.cover)
                                        : null,
                              ),
                              child: (_media == null &&
                                      (widget.existingPost == null ||
                                          widget.existingPost!.mediaUrls.isEmpty))
                                  ? const Center(
                                      child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 36,
                                          color: Colors.black54))
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // caption + date/time
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: _captionCtrl,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      hintText: 'Write a caption',
                                      hintStyle:
                                          TextStyle(color: Colors.black38),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Saved captions',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500)),
                                ),
                                const SizedBox(height: 4),
                                // date / time row
                                GestureDetector(
                                  onTap: _openSchedulePicker,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Icon(
                                                Icons.calendar_today_outlined,
                                                size: 20,
                                                color: _scheduledDate != null
                                                    ? const Color(0xFF2563EB)
                                                    : Colors.black54),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey.shade300),
                                        Expanded(
                                          child: Center(
                                            child: Icon(
                                                Icons.access_time_outlined,
                                                size: 20,
                                                color: _scheduledTime != null
                                                    ? const Color(0xFF2563EB)
                                                    : Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_scheduledDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _scheduleLabel,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Tags ─────────────────────────────────
                      _inputRow(Icons.person_outline, 'Tags', _tagsCtrl),
                      const SizedBox(height: 10),

                      // ── Topics / Hashtags ─────────────────────
                      _inputRow(Icons.tag, 'Add topics', _topicsCtrl),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Saved Hashtags',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500)),
                      ),
                      const SizedBox(height: 10),

                      // ── Location + Reminder ───────────────────
                      Row(
                        children: [
                          Expanded(
                              child: _inputRow(
                                  Icons.location_on_outlined,
                                  'Location',
                                  _locationCtrl)),
                          const SizedBox(width: 10),
                          Expanded(child: _outlineBox('Reminder')),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Music + Templates ─────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _outlineBox('Music',
                                  icon: Icons.music_note_outlined)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _outlineBox('Templates'),
                                const SizedBox(height: 2),
                                Text('Allow people to use template',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Likes & plays ─────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _outlineBox('Likes & plays'),
                          const SizedBox(height: 2),
                          Text('Hide likes and plays',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _outlineBox('Turn off comments'),
                      const SizedBox(height: 10),
                      _outlineBox('Show captions'),
                    ],
                  ),
                ),
              ),

              // ── Bottom buttons ────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _media = null;
                            _captionCtrl.clear();
                            _tagsCtrl.clear();
                            _topicsCtrl.clear();
                            _locationCtrl.clear();
                            _scheduledDate = null;
                            _scheduledTime = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isPosting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _isPosting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isScheduled ? 'Schedule' : 'Post Now',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_up, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _inputRow(IconData icon, String hint, TextEditingController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black38),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineBox(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
          ],
          Text(label,
              style:
                  const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
}

class DateTimeHelper {
  static String dayName(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[d.weekday - 1];
  }
}
