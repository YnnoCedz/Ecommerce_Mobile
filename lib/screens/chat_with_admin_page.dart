import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../services/customer_service.dart';
import '../models/chat_message.dart';

class ChatWithAdminPage extends StatefulWidget {
  const ChatWithAdminPage({super.key});

  @override
  State<ChatWithAdminPage> createState() => _ChatWithAdminPageState();
}

class _ChatWithAdminPageState extends State<ChatWithAdminPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<ChatMessage> _messages = [];
  File? _selectedImage;
  bool _loading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id') ?? 0;
    setState(() => _userId = uid);
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await CustomerService.fetchChatWithAdmin(_userId!);
      setState(() {
        _messages = messages;
        _loading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final success = await CustomerService.sendUserMessage(
      userId: _userId!,
      message: text,
      attachment: _selectedImage,
    );

    if (success) {
      _controller.clear();
      setState(() => _selectedImage = null);
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Admin"),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg.senderRole == 'user';

                        final imageUrl =
                            msg.attachmentUrl != null &&
                                    msg.attachmentUrl!.isNotEmpty
                                ? '${Config.baseUrl}/${msg.attachmentUrl}'
                                : null;

                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isUser ? Colors.red[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Image.network(
                                      imageUrl,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        print("Image error: $imageUrl");
                                        return const Icon(Icons.broken_image);
                                      },
                                    ),
                                  ),
                                if (msg.message.isNotEmpty) Text(msg.message),
                                Text(
                                  msg.timestamp,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const Divider(height: 1),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.file(_selectedImage!, height: 100),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
