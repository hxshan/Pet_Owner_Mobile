class SignupDraft {
  String firstName;
  String lastName;
  String nicNumber;
  String phone;
  String address;

  String? email;
  String? password;

  SignupDraft({
    required this.firstName,
    required this.lastName,
    required this.nicNumber,
    required this.phone,
    required this.address,
    this.email,
    this.password,
  });
}
