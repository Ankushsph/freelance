class Subscription {
  final String id;
  final String userId;
  final String planType; // 'free' or 'premium'
  final String subscriptionStatus; // 'active', 'expired', 'cancelled'
  final DateTime startDate;
  final DateTime? expiryDate;
  final String? paymentId;
  final double amount;
  final String currency;

  Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.subscriptionStatus,
    required this.startDate,
    this.expiryDate,
    this.paymentId,
    required this.amount,
    required this.currency,
  });

  bool get isPremium => planType == 'premium' && subscriptionStatus == 'active';
  bool get isFree => planType == 'free';
  bool get isExpired => subscriptionStatus == 'expired';
  
  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      planType: json['planType'] ?? 'free',
      subscriptionStatus: json['subscriptionStatus'] ?? 'active',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      paymentId: json['paymentId'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'planType': planType,
      'subscriptionStatus': subscriptionStatus,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'paymentId': paymentId,
      'amount': amount,
      'currency': currency,
    };
  }
}
