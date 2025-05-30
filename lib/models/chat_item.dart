class ChatItem {
  final int chatId;
  final int senderId;
  final String senderRole;
  final int receiverId;
  final String receiverRole;
  final String message;
  final String? attachmentUrl;
  final String timestamp;
  final bool isRead;
  final String name;
  final String avatarUrl;

  ChatItem({
    required this.chatId,
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.receiverRole,
    required this.message,
    this.attachmentUrl,
    required this.timestamp,
    required this.isRead,
    required this.name,
    required this.avatarUrl,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      chatId: int.parse(json['chat_id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      senderRole: json['sender_role'],
      receiverId: int.parse(json['receiver_id'].toString()),
      receiverRole: json['receiver_role'],
      message: json['message'],
      attachmentUrl: json['attachment_url'],
      timestamp: json['timestamp'],
      isRead: json['is_read'] == '1' || json['is_read'] == 1,
      name: json['name'] ?? 'User',
      avatarUrl: json['avatar_url'] ?? 'assets/images/default_avatar.png',
    );
  }
}
