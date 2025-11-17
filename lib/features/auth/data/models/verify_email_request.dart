class VerifyEmailRequest {
  final String token;

  VerifyEmailRequest({
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) {
    return VerifyEmailRequest(
      token: json['token'] ?? '',
    );
  }
}
