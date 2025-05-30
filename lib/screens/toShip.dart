import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/order_item.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToShipPage extends StatefulWidget {
  const ToShipPage({super.key});

  @override
  State<ToShipPage> createState() => _ToShipPageState();
}

class _ToShipPageState extends State<ToShipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderItem> _approvedOrders = [];
  bool _loading = true;
  int _selectedBottomIndex = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.index = 1;
    _fetchApprovedOrders();
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'on_the_way':
        return 'On The Way';
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Future<void> _fetchApprovedOrders() async {
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
        Uri.parse('${Config.baseUrl}/get_approved_orders.php?user_id=$userId'),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _approvedOrders =
              (data['orders'] as List)
                  .map((order) => OrderItem.fromJson(order))
                  .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('❌ Fetch approved orders failed: $e');
      setState(() => _loading = false);
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });

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
      default:
        break;
    }
  }

  void _chatSeller(int sellerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with seller ID $sellerId...')),
    );
    // TODO: Navigator.pushNamed(context, AppRoutes.chatSeller, arguments: sellerId);
  }

  void _cancelOrder(int orderId) async {
    String selectedReason = '';
    String otherReason = '';
    String additionalReason = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Cancel Order',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...[
                      'Incorrect Order Details',
                      'Change Delivery Address',
                      'Change of Mind',
                      'Took too long to Ship',
                      'Other',
                    ].map(
                      (reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value!);
                        },
                      ),
                    ),
                    if (selectedReason == 'Other') ...[
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) => otherReason = value,
                        decoration: InputDecoration(
                          labelText: 'Please specify',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (value) => additionalReason = value,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedReason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a reason')),
                      );
                      return;
                    }

                    String reasonToSend =
                        selectedReason == 'Other'
                            ? otherReason
                            : selectedReason;

                    if (reasonToSend.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please specify the reason'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context); // close the dialog

                    try {
                      final response = await http.post(
                        Uri.parse('${Config.baseUrl}/cancel_order.php'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'order_id': orderId,
                          'reason': reasonToSend,
                          'additional_reason': additionalReason,
                        }),
                      );

                      final result = jsonDecode(response.body);

                      if (result['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cancellation request sent successfully!',
                            ),
                          ),
                        );
                        _fetchApprovedOrders(); // Refresh
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Failed to cancel order',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print('❌ Cancel order error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')),
                      );
                    }
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedOrdersList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_approvedOrders.isEmpty) {
      return const Center(child: Text('No approved orders found.'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _approvedOrders.length,
        itemBuilder: (context, index) {
          final order = _approvedOrders[index];
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
                    fit: BoxFit.contain,
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
                      Text(
                        'Status: ${_formatStatus(order.orderStatus)}',
                        style: const TextStyle(
                          color: Color.fromRGBO(135, 8, 8, 1),
                          fontWeight: FontWeight.w600,
                        ),
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
                      TextButton(
                        onPressed: () => {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        child: const Text('Chat Seller'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _cancelOrder(order.orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel Order'),
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
      body: _buildApprovedOrdersList(),
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
