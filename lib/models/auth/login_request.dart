class LoginRequest {
  final String nic;
  final String password;

  LoginRequest({
    required this.nic,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': nic, 
        'password': password,
      };
}
