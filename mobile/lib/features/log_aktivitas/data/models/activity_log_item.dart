import 'user_role.dart';

class ActivityLogItem {
  final String id;
  final UserRole role;
  final String description;
  final DateTime timestamp;

  ActivityLogItem({
    required this.id,
    required this.role,
    required this.description,
    required this.timestamp,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: json['id'].toString(),
      role: UserRole.fromString(json['role'] ?? 'warga'),
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.displayName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
