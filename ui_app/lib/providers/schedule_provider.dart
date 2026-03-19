import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = false;
  String? _error;


  List<Post> get posts => _posts;
  List<Post> get filteredPosts => _filteredPosts;
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Normalize date to UTC midnight for consistent comparisons
  /// This fixes the timezone issue where dates appear one day off
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Convert UTC date back to local for display
  DateTime _toLocalDate(DateTime utcDate) {
    return DateTime(utcDate.year, utcDate.month, utcDate.day);
  }


  Set<DateTime> get scheduledDates {
    final dates = <DateTime>{};
    for (final post in _posts) {
      if (post.scheduledTime != null) {

        final date = _normalizeDate(post.scheduledTime!);
        dates.add(date);
      }
    }
    return dates;
  }


  Set<DateTime> get immediateDates {
    final dates = <DateTime>{};
    for (final post in _posts) {

      if (post.scheduledTime == null && 
          (post.status == PostStatus.pending || post.status == PostStatus.publishing)) {
        final date = _normalizeDate(post.createdAt);
        dates.add(date);
      }
    }
    return dates;
  }


  List<Post> getPostsForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    
    return _posts.where((post) {

      if (post.scheduledTime != null) {
        final postDate = _normalizeDate(post.scheduledTime!);
        return postDate.isAtSameMomentAs(normalizedDate);
      }

      if (post.scheduledTime == null && 
          (post.status == PostStatus.pending || post.status == PostStatus.publishing)) {
        final postDate = _normalizeDate(post.createdAt);
        return postDate.isAtSameMomentAs(normalizedDate);
      }
      return false;
    }).toList()

      ..sort((a, b) {
        final aTime = a.scheduledTime ?? a.createdAt;
        final bTime = b.scheduledTime ?? b.createdAt;
        return aTime.compareTo(bTime);
      });
  }


  bool hasScheduledPostsOnDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _posts.any((post) {
      if (post.scheduledTime == null) return false;
      final postDate = _normalizeDate(post.scheduledTime!);
      return postDate.isAtSameMomentAs(normalizedDate);
    });
  }


  bool hasImmediatePostsOnDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _posts.any((post) {
      if (post.scheduledTime != null) return false;
      if (post.status != PostStatus.pending && post.status != PostStatus.publishing) return false;
      final postDate = _normalizeDate(post.createdAt);
      return postDate.isAtSameMomentAs(normalizedDate);
    });
  }


  bool hasPostsOnDate(DateTime date) {
    return hasScheduledPostsOnDate(date) || hasImmediatePostsOnDate(date);
  }


  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _filterPostsBySelectedDate();
    notifyListeners();
  }


  void setCurrentMonth(DateTime month) {
    _currentMonth = month;
    notifyListeners();
  }


  void _filterPostsBySelectedDate() {
    _filteredPosts = getPostsForDate(_selectedDate);
  }


  Future<void> fetchPostsForMonth(DateTime month) async {
    _setLoading(true);
    _clearError();

    try {


      final startDate = DateTime(month.year, month.month - 1, 25);

      final endDate = DateTime(month.year, month.month + 1, 5, 23, 59, 59);


      final posts = await ApiService.getUserPosts(limit: 500);

      _posts = posts;
      _filterPostsBySelectedDate();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }


  Future<void> refresh() async {
    await fetchPostsForMonth(_currentMonth);
  }


  Future<void> cancelPost(String postId) async {
    try {
      await ApiService.cancelScheduledPost(postId);

      _posts.removeWhere((post) => post.id == postId);
      _filterPostsBySelectedDate();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}