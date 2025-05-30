import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class InChatPage extends StatefulWidget {
  final String contactName;

  const InChatPage({super.key, required this.contactName});

  @override
  State<InChatPage> createState() => _InChatPageState();
}

class _InChatPageState extends State<InChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> messages = [];

  Future<void> _sendMessage({String? imageUrl}) async {
    if (_messageController.text.isNotEmpty || imageUrl != null) {
      setState(() {
        messages.add(
          ChatMessage(
            text: _messageController.text,
            imageUrl: imageUrl,
            time: TimeOfDay.now().format(context),
            isSentByMe: true,
          ),
        );
        _messageController.clear();
      });

      // Simulate a response from the contact
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          messages.add(
            ChatMessage(
              text: "Got it!",
              time: TimeOfDay.now().format(context),
              isSentByMe: false,
            ),
          );
        });
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      _sendMessage(imageUrl: result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.contactName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(135, 8, 8, 1),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment:
                      msg.isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          msg.isSentByMe
                              ? Color.fromRGBO(135, 8, 8, 1)
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Image.asset(
                              "assets/images/${msg.imageUrl}", // Ensure the image exists
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (msg.text.isNotEmpty)
                          Text(
                            msg.text,
                            style: TextStyle(
                              color:
                                  msg.isSentByMe ? Colors.white : Colors.black,
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          msg.time,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                msg.isSentByMe
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ SafeArea + Padding to Lift the Input Box
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ), // Push input area slightly up
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Image Upload Button
                    IconButton(
                      icon: const Icon(
                        Icons.image,
                        color: Color.fromRGBO(135, 8, 8, 1),
                      ),
                      onPressed: _pickImage,
                    ),

                    // Message Input Field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // Send Button
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Color.fromRGBO(135, 8, 8, 1),
                      ),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final String time;
  final bool isSentByMe;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isSentByMe,
    this.imageUrl,
  });
}
