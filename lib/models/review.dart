class Review {
  final String fullName;
  final int rating;
  final String comment;
  final String createdAt;

  Review({
    required this.fullName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      fullName: json['full_name'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}
