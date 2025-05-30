import 'package:flutter/material.dart';
import 'package:final_ecommerce/routes.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Color.fromRGBO(135, 8, 8, 1)),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.chats);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            color: Colors.grey[400],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'My Account',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // List Tiles
          _buildSettingTile(
            context,
            title: 'My Account',
            route: AppRoutes.editProfile,
          ),
          _buildSettingTile(
            context,
            title: 'Addresses',
            route: AppRoutes.userAddresses,
          ),
          _buildSettingTile(
            context,
            title: 'Privacy Settings',
            route: AppRoutes.privacySettings,
          ),
          _buildSettingTile(
            context,
            title: 'Customer Service',
            route: AppRoutes.chatWithAdminPage,
          ),

          const Spacer(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? route,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          if (route != null) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No route set for '$title'")),
            );
          }
        },
      ),
    );
  }
}
