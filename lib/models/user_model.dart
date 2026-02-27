class User {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String? address;
  final List roles;

  final String? nicNumber;
  final bool? isNicVerified;
  final int? numberOfActivePets;
  final int? numberOfAppointments;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.roles,
    this.email,
    this.phone,
    this.address,
    this.nicNumber,
    this.isNicVerified,
    this.numberOfActivePets,
    this.numberOfAppointments,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      roles: (json['roles'] as List?) ?? [],
      nicNumber: json['nicNumber'],
      isNicVerified: json['isNicVerified'],
      numberOfActivePets: json['numberOfActivePets'] != null ? (json['numberOfActivePets'] as num).toInt() : null,
      numberOfAppointments: json['numberOfAppointments'] != null ? (json['numberOfAppointments'] as num).toInt() : null,
    );
  }

  User copyWith({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? address,
    int? numberOfActivePets,
    int? numberOfAppointments,
  }) {
    return User(
      id: id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      roles: roles,
      nicNumber: nicNumber,
      isNicVerified: isNicVerified,
      numberOfActivePets: numberOfActivePets,
      numberOfAppointments: numberOfAppointments,
    );
  }
}
