/// Model untuk informasi user
class UserInfo {
  final String name;
  final String role;
  final String rtRw;

  UserInfo({required this.name, required this.role, required this.rtRw});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      rtRw: json['rt_rw'] ?? '',
    );
  }
}
