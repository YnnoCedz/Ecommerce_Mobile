class NotificationItem {
  final String type;
  final String title;
  final String message;
  final String date;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.date,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      type: json['type'],
      title: json['title'],
      message: json['message'],
      date: json['date'],
    );
  }
}
