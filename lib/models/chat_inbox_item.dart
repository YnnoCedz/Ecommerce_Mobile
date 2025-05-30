class ChatInboxItem {
  final int sellerId;
  final String storeName;
  final String lastMessage;
  final String lastTimestamp;

  ChatInboxItem({
    required this.sellerId,
    required this.storeName,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  factory ChatInboxItem.fromJson(Map<String, dynamic> json) {
    return ChatInboxItem(
      sellerId:
          json['seller_id'] is int
              ? json['seller_id']
              : int.tryParse(json['seller_id'].toString()) ?? 0,
      storeName: json['store_name'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastTimestamp: json['last_timestamp'] ?? '',
    );
  }
}
