class User {
  final String id;
  final String firstname;
  final String lastname;
  final List roles;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      roles: json['roles'],
    );
  }
}
