class User {
  final String id;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phone;
  final String? address;
  final List roles;
  final String? profileImageUrl;

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
    this.profileImageUrl,
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
      profileImageUrl: json['profileImageUrl'] ?? json['profileImage'],
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
    String? profileImageUrl,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      roles: roles,
      nicNumber: nicNumber,
      isNicVerified: isNicVerified,
      numberOfActivePets: numberOfActivePets ?? this.numberOfActivePets,
      numberOfAppointments: numberOfAppointments ?? this.numberOfAppointments,
    );
  }
}
