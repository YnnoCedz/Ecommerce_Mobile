import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:final_ecommerce/services/address_service.dart';
import 'package:final_ecommerce/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  Map<String, String>? _selectedProvince;
  Map<String, String>? _selectedCity;
  Map<String, String>? _selectedBarangay;

  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _cities = [];
  List<Map<String, String>> _barangays = [];

  String? _userIdFile;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final provinces = await AddressService.fetchProvinces();
    setState(() {
      _provinces = provinces;
    });
  }

  Future<void> _loadCities(String provinceCode) async {
    final cities = await AddressService.fetchCities(provinceCode);
    setState(() {
      _cities = cities;
      _selectedCity = null;
      _barangays = [];
      _selectedBarangay = null;
    });
  }

  Future<void> _loadBarangays(String cityCode) async {
    final barangays = await AddressService.fetchBarangays(cityCode);
    setState(() {
      _barangays = barangays;
      _selectedBarangay = null;
    });
  }

  Future<void> _pickUserId() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _userIdFile = result.files.single.name;
      });
    }
  }

  Future<void> _signup() async {
    if (_userIdFile == null ||
        _selectedProvince == null ||
        _selectedCity == null ||
        _selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'province': _selectedProvince?['name'],
      'city': _selectedCity?['name'],
      'barangay': _selectedBarangay?['name'],
      'street': _streetController.text.trim(),
      'zip_code': _zipCodeController.text.trim(),
      'user_id_path': _userIdFile,
    };

    final success = await AuthService.registerUser(userData);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/frame1.svg',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 20,
            left: -25,
            child: Image.asset(
              'assets/images/logo_1.png',
              width: 170,
              height: 170,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 200),
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'First Name',
                              _firstNameController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInputField(
                              'Last Name',
                              _lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField('Email', _emailController),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'Password',
                        _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'Phone Number',
                        _phoneController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Province
                      _buildDropdown(
                        'Province',
                        _provinces,
                        _selectedProvince,
                        (value) {
                          setState(() => _selectedProvince = value);
                          _loadCities(value!['code']!);
                        },
                      ),
                      const SizedBox(height: 16),

                      // City
                      _buildDropdown('City', _cities, _selectedCity, (value) {
                        setState(() => _selectedCity = value);
                        _loadBarangays(value!['code']!);
                      }),

                      const SizedBox(height: 16),

                      // Barangay
                      _buildDropdown(
                        'Barangay',
                        _barangays,
                        _selectedBarangay,
                        (value) => setState(() => _selectedBarangay = value),
                      ),

                      const SizedBox(height: 16),

                      _buildInputField('Street', _streetController),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'Zip Code',
                        _zipCodeController,
                        inputType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton(
                        onPressed: _pickUserId,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 23,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          _userIdFile == null
                              ? 'Upload User ID'
                              : 'ID: $_userIdFile',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _signup,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Already have an account? Log in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  String mapToString(Map<String, String>? item) {
    return item == null ? '' : '${item['code']}-${item['name']}';
  }

  Widget _buildDropdown(
    String label,
    List<Map<String, String>> items,
    Map<String, String>? selectedItem,
    ValueChanged<Map<String, String>?> onChanged,
  ) {
    return DropdownButtonFormField<Map<String, String>>(
      value: selectedItem,
      dropdownColor: const Color.fromRGBO(135, 8, 8, 1),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<Map<String, String>>(
              value: item,
              child: Text(
                item['name']!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
