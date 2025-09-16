class LoginResponse {
  final String token;
  final String message;
  final bool success;

  LoginResponse({
    this.token = '',
    this.message = '',
    this.success = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? 'Unknown error',
      // Fix: The API returns "status" as boolean, not "success"
      success: json['status'] == true,
    );
  }
}
