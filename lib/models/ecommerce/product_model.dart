class Product {
  final String id;
  final String name;
  final double price;

  final String? category;
  final String? description;

  /// Presigned URLs for display — populated from API field `imagesUrls`.
  final List<String> imageUrls;

  /// Raw S3 keys — populated from API field `images`.
  /// Use these when building the `existingImages` payload for an update request.
  final List<String> images;

  final double? rating;
  final int? reviewCount;

  final String? storeName;
  final String? storeLocation;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.category,
    this.description,
    required this.imageUrls,
    required this.images,
    this.rating,
    this.reviewCount,
    this.storeName,
    this.storeLocation,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final store = json['store'];

    // Raw S3 keys — from `images` field
    final rawKeys = json['images'];
    final List<String> images = rawKeys is List
        ? rawKeys.map((e) => e.toString()).toList()
        : (rawKeys != null ? [rawKeys.toString()] : []);

    // Presigned display URLs — from `imagesUrls` (API spelling).
    // Fall back to `imageUrls`, then `image`/`imageUrl`, then the raw keys themselves.
    final rawUrls = json['imagesUrls'] ?? json['imageUrls'];
    final List<String> imageUrls;
    if (rawUrls is List && rawUrls.isNotEmpty) {
      imageUrls = rawUrls.map((e) => e.toString()).toList();
    } else {
      // Legacy single-image fields or fall back to raw keys as display URLs
      final legacy = json['imageUrl'] ?? json['image'];
      if (legacy != null) {
        imageUrls = [legacy.toString()];
      } else {
        imageUrls = List<String>.from(images);
      }
    }

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      imageUrls: imageUrls,
      images: images,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      reviewCount: (json['reviewCount'] is num) ? (json['reviewCount'] as num).toInt() : null,
      storeName: (store is Map) ? store['name']?.toString() : null,
      storeLocation: (store is Map) ? store['location']?.toString() : null,
    );
  }
}