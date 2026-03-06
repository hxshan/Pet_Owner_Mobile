class ClinicModel {
  final String id;
  final String name;
  final String address;
  final String phone;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => ClinicModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}

class VetInfo {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String specialization;
  final ClinicModel clinic;

  const VetInfo({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.specialization,
    required this.clinic,
  });

  String get fullName => '$firstname $lastname';

  factory VetInfo.fromJson(Map<String, dynamic> json) => VetInfo(
        id: json['id'] as String? ?? '',
        firstname: json['firstname'] as String? ?? '',
        lastname: json['lastname'] as String? ?? '',
        email: json['email'] as String? ?? '',
        specialization: json['specialization'] as String? ?? '',
        clinic: ClinicModel.fromJson(
            json['clinic'] as Map<String, dynamic>? ?? {}),
      );
}

class PetInfo {
  final String id;
  final String name;
  final String species;
  final String breed;

  const PetInfo({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
  });

  factory PetInfo.fromJson(Map<String, dynamic> json) => PetInfo(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        species: json['species'] as String? ?? '',
        breed: json['breed'] as String? ?? '',
      );
}

class AppointmentModel {
  final String id;
  final String petOwnerId;
  final PetInfo pet;
  final VetInfo veterinarian;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String confirmationStatus;

  const AppointmentModel({
    required this.id,
    required this.petOwnerId,
    required this.pet,
    required this.veterinarian,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.confirmationStatus,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'] as String? ?? '',
        petOwnerId: json['petOwner'] as String? ?? '',
        pet: PetInfo.fromJson(json['pet'] as Map<String, dynamic>? ?? {}),
        veterinarian: VetInfo.fromJson(
            json['veterinarian'] as Map<String, dynamic>? ?? {}),
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        status: json['status'] as String? ?? '',
        confirmationStatus: json['confirmationStatus'] as String? ?? '',
      );
}