class VetModel {
  final String id;
  final String name;
  final String imageUrl;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String address;
  final String distance;
  final String openStatus;
  final String phone;
  final bool isOpen;

  const VetModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.distance,
    required this.openStatus,
    required this.phone,
    required this.isOpen,
  });
}
