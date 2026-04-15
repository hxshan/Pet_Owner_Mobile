class Product {
  final String id;
  final String name;
  final double price;

  final String? category;
  final String? description;

  final List<String> imageUrls;

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
    this.rating,
    this.reviewCount,
    this.storeName,
    this.storeLocation,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final store = json['store'];

    // prefer pre-signed imageUrls, fall back to legacy images/image/imageUrl
    final rawImages = json['imageUrls'] ?? json['images'] ?? json['image'] ?? json['imageUrl'];
    final List<String> imageUrls = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : (rawImages != null ? [rawImages.toString()] : []);

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      imageUrls: imageUrls,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      reviewCount: (json['reviewCount'] is num) ? (json['reviewCount'] as num).toInt() : null,
      storeName: (store is Map) ? store['name']?.toString() : null,
      storeLocation: (store is Map) ? store['location']?.toString() : null,
    );
  }
}