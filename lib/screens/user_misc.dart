import 'package:flutter/material.dart';
import 'package:final_ecommerce/routes.dart';

class UserMiscPage extends StatefulWidget {
  const UserMiscPage({super.key});

  @override
  State<UserMiscPage> createState() => _UserMiscPageState();
}

class _UserMiscPageState extends State<UserMiscPage> {
  int _selectedIndex = 5;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.bookPage);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.moviePage);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.gamePage);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.notifications);

      case 5:
        Navigator.pushReplacementNamed(context, AppRoutes.userMiscPage);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // 🔴 Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: const Color.fromRGBO(135, 8, 8, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(
                          'assets/images/avatar1.png',
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "user",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.cart);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.chatInbox);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // My Purchases Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCard(
                title: "My Purchases",
                trailing: "View Purchase History >",
                icons: const [
                  {
                    'icon': Icons.account_balance_wallet_outlined,
                    'label': 'To Pay',
                  },
                  {'icon': Icons.local_shipping_outlined, 'label': 'To Ship'},
                  {
                    'icon': Icons.delivery_dining_outlined,
                    'label': 'To Receive',
                  },
                  {'icon': Icons.approval_outlined, 'label': 'Delivered'},
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Purchase History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCard(
                title: "View Purchase History",
                icons: const [
                  {'icon': Icons.check_circle_outline, 'label': 'Completed'},
                  {'icon': Icons.sync_alt, 'label': 'Return/Refund'},
                  {'icon': Icons.cancel_outlined, 'label': 'Cancelled'},
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

  // 🔳 Card Builder
  Widget _buildCard({
    required String title,
    String? trailing,
    required List<Map<String, dynamic>> icons,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (trailing != null)
                Text(trailing, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                icons.map((item) {
                  return GestureDetector(
                    onTap: () {
                      // 🎯 Handle tab navigation
                      if (item['label'] == 'To Pay') {
                        Navigator.pushNamed(context, AppRoutes.toPayPage);
                      } else if (item['label'] == 'To Ship') {
                        Navigator.pushNamed(context, AppRoutes.toShipPage);
                      } else if (item['label'] == 'To Receive') {
                        Navigator.pushNamed(context, AppRoutes.toReceivePage);
                      } else if (item['label'] == 'Delivered') {
                        Navigator.pushNamed(context, AppRoutes.deliveredPage);
                      } else if (item['label'] == 'Completed') {
                        Navigator.pushNamed(context, AppRoutes.completedPage);
                      } else if (item['label'] == 'Return/Refund') {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.returnRefundPage,
                        );
                      } else if (item['label'] == 'Cancelled') {
                        Navigator.pushNamed(context, AppRoutes.cancelledPage);
                      }
                    },
                    child: Column(
                      children: [
                        Icon(item['icon'], size: 28, color: Colors.black87),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
