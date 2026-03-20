import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  Subscription? _subscription;
  bool _isLoading = false;
  String? _error;

  Subscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool get isPremium => _subscription?.isPremium ?? false;
  bool get isFree => _subscription?.isFree ?? true;

  Future<void> loadSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add timeout to prevent infinite loading
      _subscription = await SubscriptionService.getMySubscription()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // Return default free subscription on timeout
              return Subscription(
                id: 'default',
                userId: '',
                planType: 'free',
                subscriptionStatus: 'active',
                startDate: DateTime.now(),
                expiryDate: DateTime.now().add(const Duration(days: 365)),
                amount: 0,
                currency: 'INR',
              );
            },
          );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // On error, set default free subscription
      _subscription = Subscription(
        id: 'default',
        userId: '',
        planType: 'free',
        subscriptionStatus: 'active',
        startDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        amount: 0,
        currency: 'INR',
      );
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkFeatureAccess(String feature) async {
    // Free features
    if (feature == 'schedule' || feature == 'basic_dashboard') {
      return true;
    }

    // Premium features
    if (isPremium) {
      return true;
    }

    return false;
  }

  Future<bool> cancelSubscription() async {
    try {
      final success = await SubscriptionService.cancelSubscription();
      if (success) {
        await loadSubscription();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
