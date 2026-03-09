class VaccinationPet {
  final String id;
  final String name;
  final String species;
  final String breed;

  const VaccinationPet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
  });

  factory VaccinationPet.fromJson(Map<String, dynamic> json) => VaccinationPet(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        species: json['species'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
      );
}

class VaccinationModel {
  final String id;
  final VaccinationPet pet;
  final String vaccineName;
  final String dose;
  final String route;
  final String manufacturer;
  final String batchNumber;
  final DateTime administeredDate;
  final DateTime? nextDueDate;
  final String status; // e.g. "Upcoming", "Completed", "Overdue"

  const VaccinationModel({
    required this.id,
    required this.pet,
    required this.vaccineName,
    required this.dose,
    required this.route,
    required this.manufacturer,
    required this.batchNumber,
    required this.administeredDate,
    required this.nextDueDate,
    required this.status,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    DateTime? nextDue;
    try {
      final raw = json['nextDueDate'] as String?;
      if (raw != null) nextDue = DateTime.parse(raw).toLocal();
    } catch (_) {}

    return VaccinationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      pet: json['pet'] is Map<String, dynamic>
          ? VaccinationPet.fromJson(json['pet'] as Map<String, dynamic>)
          : VaccinationPet(
              id: json['pet']?.toString() ?? '',
              name: '',
              species: '',
              breed: '',
            ),
      vaccineName: json['vaccineName'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      route: json['route'] as String? ?? '',
      manufacturer: json['manufacturer'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? '',
      administeredDate:
          DateTime.parse(json['administeredDate'] as String).toLocal(),
      nextDueDate: nextDue,
      status: json['status'] as String? ?? '',
    );
  }
}
