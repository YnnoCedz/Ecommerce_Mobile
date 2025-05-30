import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> selectedItems;
  final int? productId;

  const CheckoutPage({super.key, required this.selectedItems, this.productId});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedAddress;
  String? selectedVoucher;
  List<String> addressOptions = [];
  List<Map<String, dynamic>> voucherOptions = [];
  String? applicableVoucherCategory;
  bool voucherApplies = true;

  bool _loading = true;

  double get totalPrice {
    double sum = 0;
    for (var item in widget.selectedItems) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  double get discountedTotal {
    double discount = 0;

    if (selectedVoucher != null) {
      final voucher = voucherOptions.firstWhere(
        (v) => v['voucher_code'] == selectedVoucher,
        orElse: () => {},
      );

      if (voucher.isNotEmpty) {
        double discountValue =
            double.tryParse(voucher['discount'].toString()) ?? 0;
        String voucherCategory = (voucher['category'] ?? '').toString().trim();

        double eligibleAmount = 0;

        for (var item in widget.selectedItems) {
          String itemCategory = (item.category ?? '').toLowerCase().trim();

          if (itemCategory == voucherCategory) {
            eligibleAmount += item.price * item.quantity;
          }
        }

        discount = (discountValue / 100) * eligibleAmount;
      }
    }

    return (totalPrice - discount).clamp(0, totalPrice);
  }

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        print('❌ No user_id found in SharedPreferences.');
        setState(() {
          _loading = false;
        });
        return;
      }

      final addressesResponse = await http.get(
        Uri.parse('${Config.getUserAddressesEndpoint}?user_id=$userId'),
      );
      final vouchersResponse = await http.get(
        Uri.parse(Config.getVouchersEndpoint),
      );

      print(
        '📦 Address API URL: ${Config.getUserAddressesEndpoint}?user_id=$userId',
      );
      print('📦 Voucher API URL: ${Config.getVouchersEndpoint}');

      final addressData = jsonDecode(addressesResponse.body);
      final voucherData = jsonDecode(vouchersResponse.body);

      setState(() {
        if (addressData['status'] == 'success') {
          addressOptions = List<String>.from(
            addressData['addresses'].map((addr) => addr['full_address']),
          );
          selectedAddress =
              addressOptions.isNotEmpty ? addressOptions[0] : null;
        }
        if (voucherData['status'] == 'success') {
          voucherOptions = List<Map<String, dynamic>>.from(
            voucherData['vouchers'],
          );
        }
        _loading = false;
      });
    } catch (e) {
      print('❌ Failed to load checkout data: $e');
      setState(() => _loading = false);
    }
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color.fromRGBO(135, 8, 8, 1) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : widget.selectedItems.isEmpty
              ? const Center(child: Text('No items selected.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          // Address Selection
                          Text(
                            'Select Delivery Address:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedAddress,
                            onChanged: (newValue) {
                              setState(() {
                                selectedAddress = newValue!;
                              });
                            },
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            selectedItemBuilder: (context) {
                              return addressOptions.map((address) {
                                return Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 2,
                                );
                              }).toList();
                            },
                            items:
                                addressOptions.map((address) {
                                  return DropdownMenuItem(
                                    value: address,
                                    child: Text(
                                      address,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Cart Items
                          ...widget.selectedItems.map(
                            (item) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.shopName ?? 'Store Name Here',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "₱ ${item.price.toStringAsFixed(2)} x ${item.quantity}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Subtotal: ₱ ${(item.price * item.quantity).toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color.fromRGBO(135, 8, 8, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Voucher Selection
                          Text(
                            'Select Voucher:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedVoucher,
                            onChanged: (newValue) {
                              setState(() {
                                selectedVoucher = newValue;

                                final selected = voucherOptions.firstWhere(
                                  (v) => v['voucher_code'] == newValue,
                                  orElse: () => {},
                                );

                                if (selected.isNotEmpty) {
                                  applicableVoucherCategory =
                                      (selected['category'] ?? '').toString();

                                  final lowerCategory =
                                      applicableVoucherCategory!
                                          .toLowerCase()
                                          .trim();
                                  voucherApplies = widget.selectedItems.any(
                                    (item) =>
                                        (item.category ?? '')
                                            .toLowerCase()
                                            .trim() ==
                                        lowerCategory,
                                  );
                                } else {
                                  applicableVoucherCategory = null;
                                  voucherApplies = true;
                                }
                              });
                            },

                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Select voucher code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            items:
                                voucherOptions.map((voucher) {
                                  return DropdownMenuItem<String>(
                                    value: voucher['voucher_code'] as String,
                                    child: Text(
                                      voucher['voucher_code'] as String,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Total + Confirm Button
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReceiptRow(
                            "Merchandise Total:",
                            "₱ ${totalPrice.toStringAsFixed(2)}",
                          ),
                          _buildReceiptRow("Shipping Fee:", "₱ 50.00"),
                          _buildReceiptRow(
                            "Discount:",
                            "-₱ ${(totalPrice - discountedTotal).toStringAsFixed(2)}",
                          ),
                          const Divider(thickness: 1),
                          _buildReceiptRow(
                            "Total Payment:",
                            "₱ ${(discountedTotal + 50).toStringAsFixed(2)}",
                            isBold: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: Container()),
                              ElevatedButton(
                                onPressed: () async {
                                  if (!voucherApplies) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Voucher does not apply to any items in your cart.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final userId = prefs.getInt('user_id');

                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('User not logged in.'),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final response = await http.post(
                                      Uri.parse(
                                        '${Config.baseUrl}/checkout_post.php',
                                      ),
                                      headers: {
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        'user_id': userId,
                                        'cart_ids':
                                            widget.selectedItems
                                                .map((item) => item.id)
                                                .toList(),
                                        'delivery_address': selectedAddress,
                                        'voucher': selectedVoucher,
                                      }),
                                    );

                                    final result = jsonDecode(response.body);

                                    if (result['status'] == 'success') {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Order Confirmed!',
                                              ),
                                              content: Text(
                                                'Thank you for your purchase. Total Paid: ₱${result['total_paid']}',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pushNamedAndRemoveUntil(
                                                      context,
                                                      '/toPay',
                                                      (route) => false,
                                                    );
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ??
                                                'Checkout failed.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print('❌ Checkout error: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Something went wrong during checkout.',
                                        ),
                                      ),
                                    );
                                  }
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    135,
                                    8,
                                    8,
                                    1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm Order',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
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
  }
}
