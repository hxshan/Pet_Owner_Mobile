class ReviewUser {
  final String id;
  final String? name;
  final String? firstname;
  final String? lastname;

  ReviewUser({required this.id, this.name, this.firstname, this.lastname});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString(),
      firstname: json['firstname']?.toString(),
      lastname: json['lastname']?.toString(),
    );
  }

  /// Returns the best display name available
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!;
    final full = [firstname, lastname]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(' ');
    if (full.isNotEmpty) return full;
    return 'Anonymous';
  }
}

class ReviewReply {
  final String text;
  final DateTime? repliedAt;

  ReviewReply({required this.text, this.repliedAt});

  /// Returns true only when there is actual reply content
  bool get hasContent => text.trim().isNotEmpty;

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      text: json['text']?.toString() ?? '',
      repliedAt: json['repliedAt'] != null
          ? DateTime.tryParse(json['repliedAt'].toString())
          : null,
    );
  }
}

class Review {
  final String id;
  final String productId;
  final ReviewUser? user;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final ReviewReply? reply;

  Review({
    required this.id,
    required this.productId,
    this.user,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.reply,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id']?.toString() ?? '',
      productId: (json['product'] is Map
              ? json['product']['_id']
              : json['product'])
          ?.toString() ??
          '',
      user: json['user'] is Map
          ? ReviewUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      rating: (json['rating'] as num?)?.toInt() ?? 1,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      reply: json['reply'] is Map
          ? ReviewReply.fromJson(
              Map<String, dynamic>.from(json['reply'] as Map))
          : null,
    );
  }
}

class ReviewsResponse {
  final int total;
  final int page;
  final int limit;
  final List<Review> reviews;

  ReviewsResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.reviews,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['reviews'] as List?) ?? [];
    return ReviewsResponse(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      reviews: list
          .whereType<Map>()
          .map((r) => Review.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
    );
  }
}