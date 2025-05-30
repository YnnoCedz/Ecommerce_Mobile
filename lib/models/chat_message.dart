// models/chat_message.dart
class ChatMessage {
  final int senderId;
  final String senderRole;
  final int receiverId;
  final String receiverRole;
  final String message;
  final String? attachmentUrl;
  final String timestamp;
  final bool isRead;

  ChatMessage({
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    required this.message,
    this.attachmentUrl,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['sender_id'],
      senderRole: json['sender_role'],
      receiverId: json['receiver_id'],
      receiverRole: json['receiver_role'],
      message: json['message'] ?? '',
      attachmentUrl: json['attachment_url'],
      timestamp: json['timestamp'],
      isRead: json['is_read'] == 1,
    );
  }
}
