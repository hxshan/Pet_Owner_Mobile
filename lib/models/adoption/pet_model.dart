// Create this file: lib/models/pet.dart

class Pet {
  final String name;
  final String image;
  final int age;
  final String gender;
  final String location;
  final String breed;
  final bool isFavorite;

  Pet({
    required this.name,
    required this.image,
    required this.age,
    required this.gender,
    required this.location,
    required this.breed,
    this.isFavorite = false,
  });

  // Add copyWith method for easy updates
  Pet copyWith({
    String? name,
    String? image,
    int? age,
    String? gender,
    String? location,
    String? breed,
    bool? isFavorite,
  }) {
    return Pet(
      name: name ?? this.name,
      image: image ?? this.image,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      breed: breed ?? this.breed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Optional: Add toJson and fromJson for API integration
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'age': age,
      'gender': gender,
      'location': location,
      'breed': breed,
      'isFavorite': isFavorite,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'] as String,
      image: json['image'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      location: json['location'] as String,
      breed: json['breed'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}