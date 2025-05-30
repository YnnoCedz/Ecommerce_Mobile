import 'package:flutter/material.dart';
import 'package:final_ecommerce/routes.dart';
import '../services/chat_services.dart';
import '../models/chat_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<ChatItem> _chatList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final chats = await ChatService.fetchChats(userId);
      setState(() {
        _chatList = chats;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching chats: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _chatList.isEmpty
              ? const Center(child: Text('No chats found.'))
              : ListView.builder(
                itemCount: _chatList.length,
                itemBuilder: (context, index) {
                  final chat = _chatList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          chat.avatarUrl.startsWith('http')
                              ? NetworkImage(chat.avatarUrl)
                              : AssetImage(chat.avatarUrl) as ImageProvider,
                    ),
                    title: Text(
                      chat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chat.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      chat.timestamp,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.inChat,
                        arguments: chat.name,
                      );
                    },
                  );
                },
              ),
    );
  }
}
