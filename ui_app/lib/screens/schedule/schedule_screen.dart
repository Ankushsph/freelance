import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/platform_provider.dart';
import '../../widgets/schedule_calendar.dart';
import 'post_create_sheet.dart';
import 'post_detail_sheet.dart';
import '../../services/account_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? activePlatform;
  Map<String, dynamic>? activeAccountData;
  bool isLoadingAccount = true;

  @override
  void initState() {
    super.initState();
    _loadActiveAccount();
  }

  Future<void> _loadActiveAccount() async {
    try {
      final data = await AccountService.getConnectedAccounts();
      final active = data['activePlatform'] as String?;
      
      if (active != null) {
        final accounts = List<Map<String, dynamic>>.from(data['accounts'] ?? []);
        final activeAcc = accounts.firstWhere(
          (acc) => acc['platform'] == active,
          orElse: () => {},
        );
        
        setState(() {
          activePlatform = active;
          activeAccountData = activeAcc.isNotEmpty ? activeAcc : null;
          isLoadingAccount = false;
        });
      } else {
        setState(() {
          isLoadingAccount = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingAccount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleProvider(),
      child: _ScheduleBody(
        activePlatform: activePlatform,
        activeAccountData: activeAccountData,
        isLoadingAccount: isLoadingAccount,
      ),
    );
  }
}

class _ScheduleBody extends StatefulWidget {
  final String? activePlatform;
  final Map<String, dynamic>? activeAccountData;
  final bool isLoadingAccount;

  const _ScheduleBody({
    this.activePlatform,
    this.activeAccountData,
    required this.isLoadingAccount,
  });

  @override
  State<_ScheduleBody> createState() => _ScheduleBodyState();
}

class _ScheduleBodyState extends State<_ScheduleBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchPostsForMonth(
            context.read<ScheduleProvider>().currentMonth,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.activePlatform ?? 'instagram';
    final isLinkedIn = platform == 'linkedin';
    
    // Platform colors
    final platformColor = _getPlatformColor(platform);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.maybePop(context),
            ),
            if (isLinkedIn && !widget.isLoadingAccount)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _buildPlatformIcon(platform, size: 24),
              ),
          ],
        ),
        leadingWidth: isLinkedIn ? 80 : 56,
        title: isLinkedIn
            ? null
            : const Text('Schedule',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
        centerTitle: !isLinkedIn,
        actions: [
          if (isLinkedIn && widget.activeAccountData != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: widget.activeAccountData!['avatar'] != null &&
                        widget.activeAccountData!['avatar'].toString().isNotEmpty
                    ? NetworkImage(widget.activeAccountData!['avatar'])
                    : null,
                child: widget.activeAccountData!['avatar'] == null ||
                        widget.activeAccountData!['avatar'].toString().isEmpty
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
            )
          else if (!isLinkedIn)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: () => _openCreateSheet(context, DateTime.now()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('+ Post',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.error!)),
              );
              provider.clearError();
            });
          }

          return Column(
            children: [
              // ── Selected date pill (LinkedIn only) ────────────
              if (isLinkedIn)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: platformColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _selectedDateLabel(provider.selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // ── Calendar ──────────────────────────────────────
              ScheduleCalendar(
                currentMonth: provider.currentMonth,
                selectedDate: provider.selectedDate,
                scheduledDates: provider.scheduledDates,
                immediateDates: provider.immediateDates,
                onDateSelected: provider.setSelectedDate,
                onMonthChanged: (m) {
                  provider.setCurrentMonth(m);
                  provider.fetchPostsForMonth(m);
                },
                onAddTapped: (date) => _openCreateSheet(context, date),
                onEditTapped: (date) {
                  final posts = provider.getPostsForDate(date);
                  if (posts.isNotEmpty) {
                    _openDetailSheet(context, provider, posts.first);
                  }
                },
              ),

              // ── Posts panel ───────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: platformColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Text(
                          _dateLabel(provider.selectedDate),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: provider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : provider.filteredPosts.isEmpty
                                ? _emptyState()
                                : RefreshIndicator(
                                    onRefresh: provider.refresh,
                                    color: platformColor,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 24),
                                      itemCount:
                                          provider.filteredPosts.length,
                                      itemBuilder: (ctx, i) => _PostRow(
                                        post: provider.filteredPosts[i],
                                        onTap: () => _openDetailSheet(
                                            context,
                                            provider,
                                            provider.filteredPosts[i]),
                                      ),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.black;
      case 'instagram':
        return const Color(0xFF1DA1F2); // Blue theme
      default:
        return const Color(0xFF1DA1F2);
    }
  }

  Widget _buildPlatformIcon(String platform, {double size = 24}) {
    String iconName = platform;
    if (platform == 'twitter') iconName = 'x';
    if (platform == 'instagram') iconName = 'ig';
    if (platform == 'facebook') iconName = 'fb';

    try {
      return Image.asset(
        'assets/images/social/$iconName.png',
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Icon(Icons.circle, size: size),
      );
    } catch (e) {
      return Icon(Icons.circle, size: size);
    }
  }

  String _selectedDateLabel(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[d.weekday - 1]}, ${d.day}';
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _dateLabel(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final s = DateTime(d.year, d.month, d.day);
    if (s == t) return 'Today';
    if (s == t.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('MMMM d, y').format(d);
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                size: 30, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('No posts scheduled',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to create a post for this date',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 13)),
        ],
      ),
    );
  }

  void _openCreateSheet(BuildContext context, DateTime date) {
    final platformProvider = context.read<PlatformProvider>();
    // Convert platform ID (e.g. 'IG') to API name (e.g. 'instagram')
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    final platformName = platformProvider.getPlatformName(platformProvider.selectedPlatform);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostCreateSheet(
        preSelectedDate: date,
        platform: apiPlatform,
        platformDisplayName: platformName,
        onSaved: () {
          context.read<ScheduleProvider>().refresh();
        },
      ),
    );
  }

  void _openDetailSheet(
      BuildContext context, ScheduleProvider provider, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostDetailSheet(
        post: post,
        onDelete: () async {
          Navigator.pop(context);
          await provider.cancelPost(post.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Post deleted'),
                backgroundColor: Color(0xFF1DA1F2)));
          }
        },
        onEdit: () {
          Navigator.pop(context);
          _openEditSheet(context, post);
        },
      ),
    );
  }

  void _openEditSheet(BuildContext context, Post post) {
    final platformProvider = context.read<PlatformProvider>();
    final apiPlatform = platformProvider.getPlatformApiName(platformProvider.selectedPlatform);
    final platformName = platformProvider.getPlatformName(platformProvider.selectedPlatform);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostCreateSheet(
        preSelectedDate: post.scheduledTime ?? post.createdAt,
        platform: apiPlatform,
        platformDisplayName: platformName,
        existingPost: post,
        onSaved: () {
          context.read<ScheduleProvider>().refresh();
        },
      ),
    );
  }
}

// ── Post row in the blue panel ─────────────────────────────────────────────
class _PostRow extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PostRow({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = post.status == PostStatus.published;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // circle icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                color: isDone
                    ? Colors.white
                    : Colors.transparent,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF2563EB))
                  : null,
            ),
            const SizedBox(width: 12),
            // caption preview
            Expanded(
              child: Text(
                post.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 10),
            // status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDone ? 'Done' : 'To post',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
