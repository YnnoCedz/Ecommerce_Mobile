import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  String email = '';
  String phoneNumber = '';
  String password = '********';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final user = await UserService.fetchUser(userId);
      setState(() {
        email = user.email;
        phoneNumber = user.phone;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _savePrivacyChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final success = await UserService.updatePrivacy(
        userId: userId,
        email: email,
        phone: phoneNumber,
        password: password != '********' ? password : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Privacy settings updated")),
        );
        setState(() {
          if (password != '********') password = '********'; // reset masked
        });
      }
    } catch (e) {
      // Show backend message (like "Email is already in use")
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showEditDialog(
    String field,
    String currentValue,
    Function(String) onSaved, {
    bool obscure = false,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Edit $field"),
            content: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: field,
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  onSaved(controller.text.trim());
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(135, 8, 8, 1),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color.fromRGBO(135, 8, 8, 1)),
            onPressed: _savePrivacyChanges,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[400],
                    child: const Text(
                      'Account Info',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildTile(
                    title: 'Email',
                    value: email,
                    onTap:
                        () => _showEditDialog("Email", email, (val) {
                          setState(() => email = val);
                        }),
                  ),
                  _buildTile(
                    title: 'Password',
                    value: password,
                    onTap:
                        () => _showEditDialog("Password", '', (val) {
                          setState(() => password = val);
                        }, obscure: true),
                  ),
                  _buildTile(
                    title: 'Phone Number',
                    value: phoneNumber,
                    onTap:
                        () =>
                            _showEditDialog("Phone Number", phoneNumber, (val) {
                              setState(() => phoneNumber = val);
                            }),
                  ),
                ],
              ),
    );
  }

  Widget _buildTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: Colors.black54)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
