import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/address_service.dart';
import '../services/edit_address_service.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();

  List<Map<String, String>> provinces = [];
  List<Map<String, String>> cities = [];
  List<Map<String, String>> barangays = [];

  String? selectedProvinceCode;
  String? selectedCityCode;
  String? selectedBarangayCode;
  String? selectedProvinceName;
  String? selectedCityName;
  String? selectedBarangayName;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    provinces = await AddressService.fetchProvinces();
    setState(() {});
  }

  Future<void> _loadCities(String provinceCode) async {
    cities = await AddressService.fetchCities(provinceCode);
    setState(() {});
  }

  Future<void> _loadBarangays(String cityCode) async {
    barangays = await AddressService.fetchBarangays(cityCode);
    setState(() {});
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      final success = await EditAddressService.addUserAddress(
        userId: userId,
        street: _streetController.text,
        barangay: selectedBarangayName ?? '',
        city: selectedCityName ?? '',
        province: selectedProvinceName ?? '',
        zipCode: _zipController.text,
      );

      setState(() => _saving = false);

      if (success) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add address')));
      }
    }
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Container(
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

  Widget _buildDropdown({
    required String label,
    required List<Map<String, String>> items,
    required String? selectedCode,
    required void Function(String? code, String? name) onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: selectedCode,
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item['code'],
                child: Text(item['name'] ?? ''),
              );
            }).toList(),
        onChanged:
            enabled
                ? (val) {
                  final selected = items.firstWhere(
                    (item) => item['code'] == val,
                  );
                  onChanged(val, selected['name']);
                }
                : null,
        validator: (val) => val == null || val.isEmpty ? 'Select $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAddress),
        ],
      ),
      body:
          _saving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInput('Street', _streetController),
                    _buildDropdown(
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
                    _buildDropdown(
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
                    _buildDropdown(
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
