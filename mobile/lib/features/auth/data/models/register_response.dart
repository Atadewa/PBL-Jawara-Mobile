/// Register response model
class RegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final UserData? user;

  RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }
}

class UserData {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? role;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }
}
