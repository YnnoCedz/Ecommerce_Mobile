import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final user = await UserService.fetchUser(userId);
      setState(() {
        firstName = user.firstName;
        lastName = user.lastName;
        email = user.email;
        phoneNumber = user.phone;
        _loading = false;
      });
    } catch (e) {
      print('Failed to load user info: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppBar Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Color.fromRGBO(135, 8, 8, 1),
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('user_id') ?? 0;

                              final success = await UserService.updateUser(
                                userId: userId,
                                firstName: firstName,
                                lastName: lastName,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Profile updated successfully",
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to update profile"),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Profile Picture
                    Container(
                      width: double.infinity,
                      color: const Color.fromRGBO(135, 8, 8, 1),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage(
                              'assets/images/avatar1.png',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Edit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Editable Fields
                    _buildEditTile(
                      context,
                      title: "First Name",
                      value: firstName,
                      onSaved: (val) => setState(() => firstName = val),
                    ),
                    _buildEditTile(
                      context,
                      title: "Last Name",
                      value: lastName,
                      onSaved: (val) => setState(() => lastName = val),
                    ),
                    _buildEditTile(
                      context,
                      title: "Email",
                      value: email,
                      onSaved: null,
                      editable: false,
                    ),
                    _buildEditTile(
                      context,
                      title: "Phone Number",
                      value: phoneNumber,
                      onSaved: null,
                      editable: false,
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildEditTile(
    BuildContext context, {
    required String title,
    required String value,
    required Function(String)? onSaved,
    bool editable = true,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: editable ? Colors.black54 : Colors.grey,
                    fontStyle: editable ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
                if (editable) const Icon(Icons.chevron_right),
              ],
            ),
            onTap:
                editable
                    ? () => _showEditDialog(context, title, value, onSaved!)
                    : null,
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String currentValue,
    Function(String) onSaved,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
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
        );
      },
    );
  }
}
