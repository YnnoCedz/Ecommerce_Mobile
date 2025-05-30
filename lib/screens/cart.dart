import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_ecommerce/screens/checkout.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, List<CartItem>> groupedCart = {};
  bool _loading = true;

  double get totalPrice {
    double sum = 0;
    for (var group in groupedCart.values) {
      sum += group
          .where((item) => item.isSelected)
          .fold(0, (total, item) => total + (item.price * item.quantity));
    }
    return sum;
  }

  int get selectedItemCount {
    int count = 0;
    for (var group in groupedCart.values) {
      count += group.where((item) => item.isSelected).length;
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      try {
        final cartData = await CartService.fetchGroupedCart(userId);
        setState(() {
          groupedCart = cartData;
          _loading = false;
        });
      } catch (e) {
        print("❌ Failed to load cart: $e");
        setState(() => _loading = false);
      }
    } else {
      print("❌ User ID not found in SharedPreferences.");
      setState(() => _loading = false);
    }
  }

  void _toggleSelection(String shop, int index) {
    setState(() {
      groupedCart[shop]![index].isSelected =
          !groupedCart[shop]![index].isSelected;
    });
  }

  void _updateQuantity(String shop, int index, int change) async {
    final item = groupedCart[shop]![index];
    final newQuantity = (item.quantity + change).clamp(1, 99);

    setState(() {
      item.quantity = newQuantity;
    });

    try {
      await CartService.updateCartItemQuantity(
        cartItemId: item.id,
        quantity: newQuantity,
      );
    } catch (e) {
      print("❌ Failed to update quantity: $e");

      // Revert if failed
      setState(() {
        item.quantity -= change;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity.')),
      );
    }
  }

  void _checkoutSelectedItems() {
    final selectedItems =
        groupedCart.values
            .expand((items) => items)
            .where((item) => item.isSelected)
            .toList();

    if (selectedItems.isEmpty) return;

    for (var item in selectedItems) {
      if (item.quantity > item.stocks) {
        _showStockError(item.title, item.stocks);
        return;
      }
    }

    // ✅ Navigate properly passing selectedItems
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(selectedItems: selectedItems),
      ),
    );
  }

  void _showStockError(String productName, int availableStock) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Insufficient Stock'),
            content: Text(
              'The product "$productName" only has $availableStock stock left. Please adjust your quantity.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : groupedCart.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView(
                padding: const EdgeInsets.all(10),
                children:
                    groupedCart.entries.map((entry) {
                      final store = entry.key;
                      final items = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(135, 8, 8, 1),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.store, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      store,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...items.asMap().entries.map((e) {
                              final item = e.value;
                              return Dismissible(
                                key: Key('${store}_${e.key}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  setState(() {
                                    groupedCart[store]!.remove(item);
                                    if (groupedCart[store]!.isEmpty) {
                                      groupedCart.remove(store);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: item.isSelected,
                                        onChanged:
                                            (_) =>
                                                _toggleSelection(store, e.key),
                                        activeColor: const Color.fromRGBO(
                                          135,
                                          8,
                                          8,
                                          1,
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: 70,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 70,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "₱ ${item.price.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                color: Color.fromRGBO(
                                                  135,
                                                  8,
                                                  8,
                                                  1,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed:
                                                      () => _updateQuantity(
                                                        store,
                                                        e.key,
                                                        -1,
                                                      ),
                                                  icon: const Icon(
                                                    Icons.remove,
                                                  ),
                                                ),
                                                Text(item.quantity.toString()),
                                                IconButton(
                                                  onPressed:
                                                      () => _updateQuantity(
                                                        store,
                                                        e.key,
                                                        1,
                                                      ),
                                                  icon: const Icon(Icons.add),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Text(
              'Total:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              '₱ ${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromRGBO(135, 8, 8, 1),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: selectedItemCount > 0 ? _checkoutSelectedItems : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedItemCount > 0
                        ? const Color.fromRGBO(135, 8, 8, 1)
                        : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Checkout ($selectedItemCount)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
