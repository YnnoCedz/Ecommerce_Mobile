import 'package:flutter/material.dart';
import 'package:final_ecommerce/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<Map<String, dynamic>>>? _futureNotifications;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    final fetchedNotifications = NotificationService.fetchUserNotifications(
      userId,
    );

    setState(() {
      _futureNotifications = fetchedNotifications;
    });
  }

  Future<void> _refreshNotifications() async {
    await _initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child:
            _futureNotifications == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureNotifications,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No notifications found.'),
                      );
                    }

                    final notifications = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final isOrder = notif['type'] == 'order';
                        final icon =
                            isOrder ? Icons.local_shipping : Icons.message;

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(icon, color: Colors.red),
                            title: Text(
                              notif['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif['message']),
                                const SizedBox(height: 4),
                                Text(
                                  notif['date'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}
