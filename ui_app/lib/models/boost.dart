import 'package:intl/intl.dart';

enum BoostStatus {
  pending,
  approved,
  rejected,
}

class Boost {
  final String id;
  final String userId;
  final String name;
  final String contact;
  final DateTime timeSlot;
  final BoostStatus status;
  final DateTime createdAt;
  final String? message;

  Boost({
    required this.id,
    required this.userId,
    required this.name,
    required this.contact,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.message,
  });

  factory Boost.fromJson(Map<String, dynamic> json) {
    return Boost(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      contact: json['contact'] as String,
      timeSlot: DateTime.tryParse(json['timeSlot'] as String? ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      message: json['message'] as String?,
    );
  }

  static BoostStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return BoostStatus.pending;
      case 'approved':
        return BoostStatus.approved;
      case 'rejected':
        return BoostStatus.rejected;
      default:
        return BoostStatus.pending;
    }
  }

  String get statusDisplay {
    switch (status) {
      case BoostStatus.pending:
        return 'Pending';
      case BoostStatus.approved:
        return 'Approved';
      case BoostStatus.rejected:
        return 'Rejected';
    }
  }

  String get timeSlotDisplay {
    return DateFormat('MMM d, y HH:mm').format(timeSlot);
  }

  String get createdAtDisplay {
    return DateFormat('MMM d, y').format(createdAt);
  }
}