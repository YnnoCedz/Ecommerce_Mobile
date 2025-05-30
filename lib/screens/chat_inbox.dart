import 'package:final_ecommerce/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_inbox_service.dart';
import '../models/chat_inbox_item.dart';

class ChatInboxPage extends StatefulWidget {
  const ChatInboxPage({super.key});

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {
  List<ChatInboxItem> _inboxList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final chats = await ChatInboxService.fetchInbox(userId);
      setState(() {
        _inboxList = chats;
        _loading = false;
      });
    } catch (e) {
      print('Error loading inbox: $e');
      setState(() => _loading = false);
    }
  }

  String _formatDate(String dateTime) {
    try {
      return DateTime.parse(dateTime).toLocal().toString().split(' ')[0];
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _inboxList.isEmpty
              ? const Center(child: Text('No messages yet.'))
              : ListView.separated(
                itemCount: _inboxList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _inboxList[index];
                  return ListTile(
                    title: Text(item.storeName),
                    subtitle: Text(
                      item.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatDate(item.lastTimestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.messages,
                        arguments: {
                          'sellerId': item.sellerId,
                          'storeName': item.storeName,
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
