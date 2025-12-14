import 'user_role.dart';

/// Simple user representation for dummy authentication.
class AppUser {
  final String username;
  final UserRole role;
  final int? rwId;
  final int? rtId;

  const AppUser({
    required this.username,
    required this.role,
    this.rwId,
    this.rtId,
  });
}
