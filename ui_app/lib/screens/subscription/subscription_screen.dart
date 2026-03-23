import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../providers/subscription_provider.dart';
import '../../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    try {
      print('Payment success response:');
      print('Order ID: ${response.orderId}');
      print('Payment ID: ${response.paymentId}');
      print('Signature: ${response.signature}');
      
      final success = await SubscriptionService.verifyPayment(
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      print('Verification success: $success');

      if (success && mounted) {
        // Reload subscription data
        await context.read<SubscriptionProvider>().loadSubscription();
        
        // Wait a bit to ensure state is updated
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium subscription activated!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          // Return true to indicate successful upgrade
          Navigator.pop(context, true);
        }
      } else {
        _showError('Payment verification failed');
      }
    } catch (e) {
      print('Error in payment success handler: $e');
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showError('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showError('External wallet selected: ${response.walletName}');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _upgradeToPremium() async {
    setState(() => _isProcessing = true);

    try {
      // Create Razorpay order
      print('Creating Razorpay order...');
      final orderData = await SubscriptionService.createOrder();
      
      print('Order data received: $orderData');
      print('Key ID: ${orderData['keyId']}');
      print('Amount: ${orderData['amount']}');
      print('Order ID: ${orderData['orderId']}');

      var options = {
        'key': orderData['keyId'],
        'amount': orderData['amount'],
        'currency': orderData['currency'],
        'name': 'KonnectMedia',
        'description': 'Premium Subscription - ₹999/month',
        'order_id': orderData['orderId'],
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#6A5AE0'}
      };

      print('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      print('Error in _upgradeToPremium: $e');
      _showError('Failed to create order: ${e.toString()}');
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Subscription',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Free Plan Card
                _buildPlanCard(
                  title: 'Free',
                  price: '₹0',
                  period: '/ month',
                  features: [
                    _Feature('Post scheduling', true),
                    _Feature('1 Account per platform', true),
                    _Feature('AI Captions & Hashtags', false),
                    _Feature('Advanced Analytics', false),
                    _Feature('Trends Discovery', false),
                    _Feature('Boost Consultation', false),
                  ],
                  isPremium: false,
                  isCurrentPlan: provider.isFree,
                ),
                const SizedBox(height: 20),

                // Premium Plan Card
                _buildPlanCard(
                  title: 'Premium',
                  price: '₹999',
                  period: '/ month',
                  features: [
                    _Feature('Post scheduling', true),
                    _Feature('1 Account per platform', true),
                    _Feature('AI Captions & Hashtags', true, isPremium: true),
                    _Feature('Advanced Analytics Dashboard', true, isPremium: true),
                    _Feature('Global Trends Discovery', true, isPremium: true),
                    _Feature('Boost Consultation Access', true, isPremium: true),
                  ],
                  isPremium: true,
                  isCurrentPlan: provider.isPremium,
                  onUpgrade: _isProcessing ? null : _upgradeToPremium,
                ),

                if (provider.isPremium && provider.subscription != null) ...[
                  const SizedBox(height: 30),
                  _buildSubscriptionInfo(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<_Feature> features,
    required bool isPremium,
    required bool isCurrentPlan,
    VoidCallback? onUpgrade,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPremium)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Color(0xFFFFA500)),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Color(0xFFFFA500),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((f) => _buildFeatureRow(f)),
          if (isPremium && !isCurrentPlan && onUpgrade != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_Feature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: feature.included
                ? (feature.isPremium ? const Color(0xFFFFA500) : Colors.green)
                : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.text,
              style: TextStyle(
                fontSize: 14,
                color: feature.included ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          if (feature.isPremium && feature.included)
            const Icon(Icons.star, size: 16, color: Color(0xFFFFA500)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfo(SubscriptionProvider provider) {
    final sub = provider.subscription!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6A5AE0), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _infoRow('Status', sub.subscriptionStatus.toUpperCase()),
          _infoRow('Started', _formatDate(sub.startDate)),
          if (sub.expiryDate != null)
            _infoRow('Expires', _formatDate(sub.expiryDate!)),
          if (sub.daysUntilExpiry > 0 && sub.daysUntilExpiry <= 7)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your Premium plan will expire in ${sub.daysUntilExpiry} days',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Feature {
  final String text;
  final bool included;
  final bool isPremium;

  _Feature(this.text, this.included, {this.isPremium = false});
}
