class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final String dob;
  final String? lifeStatus;
  final String? overallHealth;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.gender,
    required this.dob,
    this.lifeStatus, this.overallHealth,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'],
      name: json['name'] ?? 'Unnamed',
      species: json['species'] ?? 'Unknown',
      breed: json['breed'] ?? '-',
      gender: json['gender'] ?? 'Unknown',
      dob: json['dob'],
      lifeStatus: json['lifeStatus'],
      overallHealth: json['health'],
    );
  }
}
