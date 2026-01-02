class SignupRequest {
  final String nicNumber;
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String phone;
  final String address;

  SignupRequest({
    required this.nicNumber,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'nicNumber': nicNumber,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    };
  }
}
