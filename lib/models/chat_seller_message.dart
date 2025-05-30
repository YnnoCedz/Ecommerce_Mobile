// FILE: lib/models/chat_seller_message.dart

class SellerChatMessage {
  final String message;
  final String? attachmentUrl;
  final String timestamp;
  final int senderId;
  final int receiverId;
  final String senderRole;
  final String senderName;

  SellerChatMessage({
    required this.message,
    this.attachmentUrl,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    required this.senderRole,
    required this.senderName,
  });

  factory SellerChatMessage.fromJson(Map<String, dynamic> json) {
    return SellerChatMessage(
      message: json['message']?.toString() ?? '',
      attachmentUrl: json['attachment_url']?.toString(),
      timestamp: json['timestamp']?.toString() ?? '',
      senderId: int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
      receiverId: int.tryParse(json['receiver_id']?.toString() ?? '') ?? 0,
      senderRole: json['sender_role']?.toString() ?? 'user',
      senderName: json['sender_name']?.toString() ?? 'Unknown',
    );
  }
}
