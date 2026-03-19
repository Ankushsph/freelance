import 'package:flutter/material.dart';
import '../../models/boost.dart';
import '../../services/api_service.dart';

class BoostHistoryScreen extends StatefulWidget {
  const BoostHistoryScreen({super.key});

  @override
  State<BoostHistoryScreen> createState() => _BoostHistoryScreenState();
}

class _BoostHistoryScreenState extends State<BoostHistoryScreen> {
  List<Boost> _boosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBoosts();
  }

  Future<void> _loadBoosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final boostsData = await ApiService.getUserBoosts();
      final boosts = boostsData.map((json) => Boost.fromJson(json)).toList();
      setState(() {
        _boosts = boosts;
        _isLoading = false;
      });
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('User not logged in')) {
        errorMsg = 'Please login to view boost history';
      } else if (errorMsg.contains('User ID not found')) {
        errorMsg = 'Unable to get user information';
      } else if (errorMsg.contains('SocketException') || errorMsg.contains('Connection')) {
        errorMsg = 'Unable to connect to server';
      }
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    }
  }

  int get _totalCount => _boosts.length;
  int get _pendingCount => _boosts.where((b) => b.status == BoostStatus.pending).length;
  int get _approvedCount => _boosts.where((b) => b.status == BoostStatus.approved).length;
  int get _rejectedCount => _boosts.where((b) => b.status == BoostStatus.rejected).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Boost History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _boosts.isEmpty
                  ? _buildEmpty()
                  : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading boost history',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadBoosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_launch, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Boost History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't requested any boost yet.\nBook a slot to get started!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadBoosts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCountCards(),
            const SizedBox(height: 20),
            _buildBoostList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildCountCard(
              label: 'Total',
              count: _totalCount,
              color: Colors.blue,
              icon: Icons.rocket_launch,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCountCard(
              label: 'Pending',
              count: _pendingCount,
              color: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCountCard(
              label: 'Approved',
              count: _approvedCount,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCountCard(
              label: 'Rejected',
              count: _rejectedCount,
              color: Colors.red,
              icon: Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Your Boosts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _boosts.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final boost = _boosts[index];
                return _buildBoostItem(boost);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoostItem(Boost boost) {
    Color statusColor;
    IconData statusIcon;

    switch (boost.status) {
      case BoostStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case BoostStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case BoostStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booked: ${boost.timeSlotDisplay}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Requested: ${boost.createdAtDisplay}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (boost.message != null && boost.message!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            boost.message!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              boost.statusDisplay,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}