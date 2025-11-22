/// Register request model
class RegisterRequest {
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String? role;

  RegisterRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
    };
  }
}
