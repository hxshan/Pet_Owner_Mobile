class Product {
  final String id;
  final String name;
  final double price;

  final String? category;
  final String? description;

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
    required this.images,
    this.rating,
    this.reviewCount,
    this.storeName,
    this.storeLocation,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final store = json['store'];

    // images could be ["url1","url2"] OR "url"
    final rawImages = json['images'] ?? json['image'] ?? json['imageUrl'];
    final List<String> images = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : (rawImages != null ? [rawImages.toString()] : []);

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['priceCents'] is num) ? (json['priceCents'] as num).toDouble() : 0.0,
      category: json['category']?.toString(),
      description: json['description']?.toString(),
      images: images,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      reviewCount: (json['reviewCount'] is num) ? (json['reviewCount'] as num).toInt() : null,
      storeName: (store is Map) ? store['name']?.toString() : null,
      storeLocation: (store is Map) ? store['location']?.toString() : null,
    );
  }
}