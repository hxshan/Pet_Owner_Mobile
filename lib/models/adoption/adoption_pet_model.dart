class AdoptionPet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int? age;
  final String gender;
  final String size;
  final String? energyLevel;
  final bool? goodWithKids;
  final bool? goodWithPets;
  final String? description;
  final String? color;
  final String? profileImageUrl;
  final List<String> photos;
  final double adoptionFee;
  final String? adoptionCenterName;
  final double? score;
  final bool isFavorite;

  AdoptionPet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    this.age,
    required this.gender,
    required this.size,
    this.energyLevel,
    this.goodWithKids,
    this.goodWithPets,
    this.description,
    this.color,
    this.profileImageUrl,
    this.photos = const [],
    this.adoptionFee = 0,
    this.adoptionCenterName,
    this.score,
    this.isFavorite = false,
  });

  /// Profile image first, then first photo, else empty
  String get primaryImage =>
      (profileImageUrl != null && profileImageUrl!.isNotEmpty)
          ? profileImageUrl!
          : (photos.isNotEmpty ? photos.first : '');

  /// Location label shown in UI
  String get locationLabel => adoptionCenterName ?? 'Adoption Center';

  AdoptionPet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    String? size,
    String? energyLevel,
    bool? goodWithKids,
    bool? goodWithPets,
    String? description,
    String? color,
    String? profileImageUrl,
    List<String>? photos,
    double? adoptionFee,
    String? adoptionCenterName,
    double? score,
    bool? isFavorite,
  }) {
    return AdoptionPet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      energyLevel: energyLevel ?? this.energyLevel,
      goodWithKids: goodWithKids ?? this.goodWithKids,
      goodWithPets: goodWithPets ?? this.goodWithPets,
      description: description ?? this.description,
      color: color ?? this.color,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      photos: photos ?? this.photos,
      adoptionFee: adoptionFee ?? this.adoptionFee,
      adoptionCenterName: adoptionCenterName ?? this.adoptionCenterName,
      score: score ?? this.score,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'size': size,
      'energyLevel': energyLevel,
      'goodWithKids': goodWithKids,
      'goodWithPets': goodWithPets,
      'description': description,
      'color': color,
      'photos': photos,
      'adoptionFee': adoptionFee,
      'adoptionCenterName': adoptionCenterName,
      'score': score,
      'isFavorite': isFavorite,
    };
  }

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
    // photosUrls from backend, fall back to legacy 'photos' field
    final rawPhotos = json['photosUrls'] ?? json['photos'];
    final List<String> photoList = rawPhotos is List
        ? rawPhotos.map((e) => e.toString()).toList()
        : [];

    // profileImageUrl — dedicated profile image field (used directly in constructor)

    // score may come from recommendation endpoint
    double? scoreVal;
    if (json['score'] != null) {
      scoreVal = (json['score'] as num).toDouble();
    }

    // adoptionFee may be int or double
    double fee = 0;
    if (json['adoptionFee'] != null) {
      fee = (json['adoptionFee'] as num).toDouble();
    }

    // adoptionCenter nested object or flat name
    String? centerName;
    if (json['adoptionCenter'] is Map) {
      centerName = json['adoptionCenter']['name'] as String?;
    } else if (json['adoptionCenterName'] is String) {
      centerName = json['adoptionCenterName'] as String;
    }

    return AdoptionPet(
      id: json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      age: json['age'] as int?,
      gender: json['gender'] as String? ?? '',
      size: json['size'] as String? ?? '',
      energyLevel: json['energyLevel'] as String?,
      goodWithKids: json['goodWithKids'] as bool?,
      goodWithPets: json['goodWithPets'] as bool?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      photos: photoList,
      adoptionFee: fee,
      adoptionCenterName: centerName,
      score: scoreVal,
      isFavorite: false,
    );
  }
}

/// Holds the result from the recommendation endpoint
class RecommendationResult {
  final List<AdoptionPet> pets;
  final int totalCandidates;

  const RecommendationResult({
    required this.pets,
    required this.totalCandidates,
  });
}

/// Represents a user's adoption application
class AdoptionApplication {
  final String id;
  final String petId;
  final String petName;
  final String? petPhoto;
  final String status;
  final DateTime createdAt;

  const AdoptionApplication({
    required this.id,
    required this.petId,
    required this.petName,
    this.petPhoto,
    required this.status,
    required this.createdAt,
  });

  factory AdoptionApplication.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'];
    String petName = '';
    String petId = '';
    String? petPhoto;

    if (pet is Map) {
      petName = pet['name']?.toString() ?? '';
      petId = pet['_id']?.toString() ?? '';
      // prefer profileImageUrl, fall back to first photo in photosUrls/photos
      if (pet['profileImageUrl'] != null &&
          (pet['profileImageUrl'] as String).isNotEmpty) {
        petPhoto = pet['profileImageUrl'] as String;
      } else {
        final photos = pet['photosUrls'] ?? pet['photos'];
        if (photos is List && photos.isNotEmpty) {
          petPhoto = photos.first.toString();
        }
      }
    } else if (pet is String) {
      petId = pet;
    }

    return AdoptionApplication(
      id: json['_id']?.toString() ?? '',
      petId: petId,
      petName: petName,
      petPhoto: petPhoto,
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
