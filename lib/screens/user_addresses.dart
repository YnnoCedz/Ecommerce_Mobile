import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_address.dart';
import '../services/edit_address_service.dart';
import '../screens/edit_address.dart'; // make sure this page exists
import '../routes.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  UserAddress? _mainAddress;
  List<UserAddress> _additionalAddresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllAddresses();
  }

  Future<void> _fetchAllAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      final main = await EditAddressService.getUserMainAddress(userId);
      final others = await EditAddressService.getUserAdditionalAddresses(
        userId,
      );

      setState(() {
        _mainAddress = main;
        _additionalAddresses = others;
        _loading = false;
      });
    } catch (e) {
      print('❌ Error fetching addresses: $e');
      setState(() => _loading = false);
    }
  }

  Widget _buildAddressCard(UserAddress addr, {bool isMain = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: const Text(
          'Saved Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${addr.street}, ${addr.barangay}, ${addr.city}, ${addr.province}, ${addr.zipCode}',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAddressPage(address: addr),
                  ),
                );
                if (updated == true) _fetchAllAddresses();
              },
            ),
            if (!isMain) // ❌ Hide delete for Main Address
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Delete Address'),
                          content: const Text(
                            'Are you sure you want to delete this address?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    final deleted = await EditAddressService.deleteUserAddress(
                      addr.id,
                    );
                    if (!mounted) return;
                    if (deleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address deleted')),
                      );
                      _fetchAllAddresses();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete address'),
                        ),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<UserAddress> addresses, {
    bool isMain = false,
    VoidCallback? onEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(135, 8, 8, 1),
                ),
              ),
              if (onEdit != null && !isMain)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
        if (addresses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No address found.'),
          )
        else
          ...addresses.map((a) => _buildAddressCard(a, isMain: isMain)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Add Address',
            onPressed: () async {
              try {
                final added = await Navigator.pushNamed(
                  context,
                  AppRoutes.addAddress,
                );
                if (added == true) {
                  _fetchAllAddresses();
                }
              } catch (e) {
                print("❌ Navigation to AddAddressPage failed: $e");
              }
            },
          ),
        ],
      ),

      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Main Address',
                      _mainAddress != null ? [_mainAddress!] : [],
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditAddressPage(address: _mainAddress!),
                          ),
                        );
                        _fetchAllAddresses();
                      },
                    ),
                    _buildSection('Other Addresses', _additionalAddresses),
                  ],
                ),
              ),
    );
  }
}
