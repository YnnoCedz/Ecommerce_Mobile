import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../models/order_item.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnRefundPage extends StatefulWidget {
  const ReturnRefundPage({super.key});

  @override
  State<ReturnRefundPage> createState() => _ReturnRefundPageState();
}

class _ReturnRefundPageState extends State<ReturnRefundPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderItem> _completedOrders = [];
  bool _loading = true;
  int _selectedBottomIndex = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.index = 5;
    _fetchReturnedOrders();
  }

  Future<void> _fetchReturnedOrders() async {
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
        Uri.parse('${Config.baseUrl}/get_returns.php?user_id=$userId'),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _completedOrders =
              (data['orders'] as List)
                  .map((order) => OrderItem.fromJson(order))
                  .toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('❌ Fetch completed orders failed: $e');
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

  Widget _buildCompletedOrdersList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_completedOrders.isEmpty) {
      return const Center(child: Text('No Returned/Refunded orders found.'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _completedOrders.length,
        itemBuilder: (context, index) {
          final order = _completedOrders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            child: ListTile(
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
                    'Status: Completed',
                    style: const TextStyle(
                      color: Color.fromRGBO(135, 8, 8, 1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
          isScrollable: true, // ➡️ added so that 7 tabs won't be squeezed
          tabs: const [
            Tab(text: 'To Pay'),
            Tab(text: 'To Ship'),
            Tab(text: 'To Receive'),
            Tab(text: 'To Rate'),
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
      body: _buildCompletedOrdersList(),
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
