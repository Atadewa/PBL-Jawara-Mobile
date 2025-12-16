/// User context model from backend /auth/me endpoint
class UserContextModel {
  final Map<String, dynamic> user;
  final List<String> roles;
  final Map<String, dynamic> scope;

  UserContextModel({
    required this.user,
    required this.roles,
    required this.scope,
  });

  factory UserContextModel.fromJson(Map<String, dynamic> json) {
    return UserContextModel(
      user: json['user'] as Map<String, dynamic>? ?? {},
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      scope: json['scope'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user, 'roles': roles, 'scope': scope};
  }

  /// Get user ID
  String? get userId => user['id'] as String?;

  /// Get user email
  String? get email => user['email'] as String?;

  /// Get user name
  String? get name => user['name'] as String?;

  /// Get is_active status
  bool get isActive => user['is_active'] as bool? ?? false;

  /// Get mode from scope
  String? get mode => scope['mode'] as String?;

  /// Get RW from scope (as int)
  int? get rw {
    final value = scope['rw'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Get RT from scope (as int)
  int? get rt {
    final value = scope['rt'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user has any of the given roles
  bool hasAnyRole(List<String> roleList) {
    return roleList.any((role) => roles.contains(role));
  }

  /// Get primary role (first role in the list)
  String? get primaryRole => roles.isNotEmpty ? roles.first : null;
}
