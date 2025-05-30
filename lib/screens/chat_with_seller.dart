import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_seller_message.dart';
import '../services/chat_seller_services.dart';
import '../config.dart';

class ChatWithSellerPage extends StatefulWidget {
  final String storeName;
  final int sellerId;

  const ChatWithSellerPage({
    super.key,
    required this.storeName,
    required this.sellerId,
  });

  @override
  State<ChatWithSellerPage> createState() => _ChatWithSellerPageState();
}

class _ChatWithSellerPageState extends State<ChatWithSellerPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<SellerChatMessage> _sellerMessages = [];
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
    _userId = prefs.getInt('user_id');
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ChatService.fetchMessagesWithSeller(
        userId: _userId!,
        sellerId: widget.sellerId,
      );
      setState(() {
        _sellerMessages = messages;
        _loading = false;
      });
    } catch (e) {
      print('Error loading seller messages: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final success = await ChatService.sendSellerMessage(
      userId: _userId!,
      sellerId: widget.sellerId,
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
        title: Text(widget.storeName),
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
                      itemCount: _sellerMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _sellerMessages[index];
                        final isUser = msg.senderRole == 'user';

                        final imageUrl =
                            msg.attachmentUrl?.isNotEmpty == true
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
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.broken_image),
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
