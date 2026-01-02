class SignupResponse {
  final String message;
  final String? note;

  SignupResponse({required this.message, this.note});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'] ?? 'Signup successful',
      note: json['note'],
    );
  }
}
