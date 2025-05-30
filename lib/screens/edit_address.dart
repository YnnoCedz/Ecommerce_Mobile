import 'package:flutter/material.dart';
import '../models/user_address.dart';
import '../services/edit_address_service.dart';
import '../services/address_service.dart';

class EditAddressPage extends StatefulWidget {
  final UserAddress address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _zipController;
  bool _updating = false;

  List<Map<String, String>> provinces = [];
  List<Map<String, String>> cities = [];
  List<Map<String, String>> barangays = [];

  String? selectedProvinceCode;
  String? selectedCityCode;
  String? selectedBarangayCode;

  String? selectedProvinceName;
  String? selectedCityName;
  String? selectedBarangayName;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address.street);
    _zipController = TextEditingController(text: widget.address.zipCode);

    selectedProvinceName = widget.address.province;
    selectedCityName = widget.address.city;
    selectedBarangayName = widget.address.barangay;

    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      provinces = await AddressService.fetchProvinces();
      final match = provinces.firstWhere(
        (e) => e['name'] == selectedProvinceName,
        orElse: () => {},
      );
      selectedProvinceCode = match['code'];
      if (!mounted) return;
      setState(() {});
      if (selectedProvinceCode != null && selectedProvinceCode!.isNotEmpty) {
        await _loadCities(selectedProvinceCode!);
      }
    } catch (e) {
      print('❌ Failed to load provinces: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load provinces')));
    }
  }

  Future<void> _loadCities(String provinceCode) async {
    try {
      cities = await AddressService.fetchCities(provinceCode);
      final match = cities.firstWhere(
        (e) => e['name'] == selectedCityName,
        orElse: () => {},
      );
      selectedCityCode = match['code'];
      if (!mounted) return;
      setState(() {});
      if (selectedCityCode != null && selectedCityCode!.isNotEmpty) {
        await _loadBarangays(selectedCityCode!);
      }
    } catch (e) {
      print('❌ Failed to load cities: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load cities')));
    }
  }

  Future<void> _loadBarangays(String cityCode) async {
    try {
      barangays = await AddressService.fetchBarangays(cityCode);
      final match = barangays.firstWhere(
        (e) => e['name'] == selectedBarangayName,
        orElse: () => {},
      );
      selectedBarangayCode = match['code'];
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('❌ Failed to load barangays: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load barangays')));
    }
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _updating = true);

      final updated = await EditAddressService.updateUserOrAdditionalAddress(
        userId: widget.address.userId,
        street: _streetController.text,
        barangay: selectedBarangayName ?? '',
        city: selectedCityName ?? '',
        province: selectedProvinceName ?? '',
        zipCode: _zipController.text,
      );

      if (!mounted) return;
      setState(() => _updating = false);

      if (updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update address')),
        );
      }
    }
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator:
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildMapDropdown({
    required String label,
    required List<Map<String, String>> items,
    required String? selectedCode,
    required Function(String? code, String? name) onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: enabled ? selectedCode : null,
        items:
            enabled && items.isNotEmpty
                ? items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['code'],
                        child: Text(item['name'] ?? ''),
                      ),
                    )
                    .toList()
                : [],
        onChanged:
            enabled && items.isNotEmpty
                ? (val) {
                  final selected = items.firstWhere(
                    (item) => item['code'] == val,
                  );
                  onChanged(val, selected['name']);
                }
                : null,
        validator:
            (val) =>
                enabled
                    ? (val == null || val.isEmpty ? 'Select $label' : null)
                    : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('Confirm Save'),
                      content: const Text('Do you want to save this address?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
              );
              if (confirmed == true) _saveAddress();
            },
          ),
        ],
      ),
      body:
          _updating
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInput('Street', _streetController),
                    _buildMapDropdown(
                      label: 'Province',
                      items: provinces,
                      selectedCode: selectedProvinceCode,
                      onChanged: (code, name) {
                        selectedProvinceCode = code;
                        selectedProvinceName = name;
                        selectedCityCode = null;
                        selectedCityName = null;
                        selectedBarangayCode = null;
                        selectedBarangayName = null;
                        _loadCities(code!);
                      },
                    ),
                    _buildMapDropdown(
                      label: 'City/Municipality',
                      items: cities,
                      selectedCode: selectedCityCode,
                      onChanged: (code, name) {
                        selectedCityCode = code;
                        selectedCityName = name;
                        selectedBarangayCode = null;
                        selectedBarangayName = null;
                        _loadBarangays(code!);
                      },
                      enabled: selectedProvinceCode != null,
                    ),
                    _buildMapDropdown(
                      label: 'Barangay',
                      items: barangays,
                      selectedCode: selectedBarangayCode,
                      onChanged: (code, name) {
                        selectedBarangayCode = code;
                        selectedBarangayName = name;
                      },
                      enabled: selectedCityCode != null,
                    ),
                    _buildInput('Zip Code', _zipController, isNumeric: true),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _zipController.dispose();
    super.dispose();
  }
}
