import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/order_item.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveredPage extends StatefulWidget {
  const DeliveredPage({super.key});

  @override
  State<DeliveredPage> createState() => _DeliveredPageState();
}

class _DeliveredPageState extends State<DeliveredPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderItem> _deliveredOrders = [];
  bool _loading = true;
  int _selectedBottomIndex = 5;
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.index = 3;
    _fetchDeliveredOrders();
  }

  Future<void> _fetchDeliveredOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        setState(() => _loading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/get_delivered_orders.php?user_id=$userId'),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _deliveredOrders =
              (data['orders'] as List)
                  .map((order) => OrderItem.fromJson(order))
                  .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('❌ Fetch delivered orders failed: $e');
      setState(() => _loading = false);
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() => _selectedBottomIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.bookPage);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.moviePage);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.gamePage);
        break;
      case 5:
        Navigator.pushNamed(context, AppRoutes.userMiscPage);
        break;
    }
  }

  Future<void> _confirmReceived(int orderId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Confirm Received',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you have received this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromRGBO(135, 8, 8, 1)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}/confirm_receive.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'order_id': orderId}),
        );

        final result = jsonDecode(response.body);

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order confirmed as received!')),
          );
          _fetchDeliveredOrders();
          _showRateProductModal(orderId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to confirm.')),
          );
        }
      } catch (e) {
        print('❌ Confirm receive error: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Something went wrong.')));
      }
    }
  }

  Future<void> _requestRefund(int orderId) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Request Refund'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for refund',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) return;

                  final response = await http.post(
                    Uri.parse('${Config.baseUrl}/request_refund.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'order_id': orderId,
                      'reason': reason,
                      'additional_reason': '',
                    }),
                  );

                  final result = json.decode(response.body);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  void _showRateProductModal(int orderId) {
    TextEditingController reviewController = TextEditingController();
    _currentRating = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Rate Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How was the product?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _currentRating = (index + 1).toDouble();
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          color:
                              (index < _currentRating)
                                  ? Colors.amber
                                  : Colors.grey,
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Write a review (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color.fromRGBO(135, 8, 8, 1)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentRating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a rating!'),
                        ),
                      );
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getInt('user_id');

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse('${Config.baseUrl}/submit_rating.php'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'user_id': userId,
                          'order_id': orderId,
                          'rating': _currentRating,
                          'review': reviewController.text.trim(),
                        }),
                      );

                      final result = jsonDecode(response.body);

                      if (result['status'] == 'success') {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thanks for your feedback!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Failed to submit rating.',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print('❌ Submit rating error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _requestRefundModal(int orderId) async {
    String selectedReason = '';
    String additionalReason = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              title: const Text(
                'Request Return/Refund',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      'Received Damaged Product',
                      'Wrong Item Delivered',
                      'Item No Longer Needed',
                      'Late Delivery',
                      'Other',
                    ].map(
                      (reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged:
                            (value) => setState(() => selectedReason = value!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => additionalReason = value,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedReason.trim().isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a reason')),
                      );
                      return;
                    }

                    if (!mounted) return;
                    Navigator.pop(context);

                    try {
                      final response = await http.post(
                        Uri.parse('${Config.baseUrl}/request_refund.php'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'order_id': orderId,
                          'reason': selectedReason,
                          'additional_reason': additionalReason,
                        }),
                      );

                      final result = jsonDecode(response.body);
                      if (!mounted) return;

                      if (result['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refund request sent!')),
                        );
                        _fetchDeliveredOrders();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ??
                                  'Failed to request return/refund',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDeliveredOrdersList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_deliveredOrders.isEmpty) {
      return const Center(child: Text('No delivered orders yet.'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _deliveredOrders.length,
        itemBuilder: (context, index) {
          final order = _deliveredOrders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Image.network(
                    '${Config.imageBaseUrl}/${order.imagePath}',
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                  ),
                  title: Text(
                    order.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₱ ${order.totalPrice.toStringAsFixed(2)}'),
                      Text('Quantity: ${order.quantity}'),
                      const SizedBox(height: 4),
                      const Text(
                        'Status: Delivered',
                        style: TextStyle(color: Color.fromRGBO(135, 8, 8, 1)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _requestRefundModal(order.orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: const Text('Return/Refund'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _confirmReceived(order.orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: const Text('Confirm'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'To Pay'),
            Tab(text: 'To Ship'),
            Tab(text: 'To Receive'),
            Tab(text: 'Delivered'),
            Tab(text: 'Completed'),
            Tab(text: 'Return/Refund'),
            Tab(text: 'Cancelled'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushNamed(context, AppRoutes.toPayPage);
            } else if (index == 1) {
              Navigator.pushNamed(context, AppRoutes.toShipPage);
            } else if (index == 2) {
              Navigator.pushNamed(context, AppRoutes.toReceivePage);
            } else if (index == 3) {
              Navigator.pushNamed(context, AppRoutes.deliveredPage);
            } else if (index == 4) {
              Navigator.pushNamed(context, AppRoutes.completedPage);
            } else if (index == 5) {
              Navigator.pushNamed(context, AppRoutes.returnRefundPage);
            } else if (index == 6) {
              Navigator.pushNamed(context, AppRoutes.cancelledPage);
            }
          },
        ),
      ),
      body: _buildDeliveredOrdersList(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: const Color.fromRGBO(135, 8, 8, 1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notify',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
