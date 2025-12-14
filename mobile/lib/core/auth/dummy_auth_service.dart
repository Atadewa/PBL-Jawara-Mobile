import 'app_user.dart';
import 'user_role.dart';

/// Dummy authentication service with hardcoded credentials.
class DummyAuthService {
  DummyAuthService();

  static final Map<String, String> _credentials = {
    'admin': 'admin',
    'ketuarw': 'ketuarw',
    'ketuart': 'ketuart',
    'sekretaris': 'sekretaris',
    'bendahara': 'bendahara',
    'warga': 'warga',
  };

  static final Map<String, AppUser> _users = {
    for (final username in _credentials.keys) username: _buildUser(username),
  };

  Future<AppUser?> login(String username, String password) async {
    final normalizedUsername = username.trim().toLowerCase();
    final expectedPassword = _credentials[normalizedUsername];

    if (expectedPassword != null && expectedPassword == password) {
      return _users[normalizedUsername];
    }

    return null;
  }

  static AppUser _buildUser(String username) {
    final role = UserRole.fromUsername(username);

    switch (role) {
      case UserRole.ketuaRw:
        return AppUser(username: username, role: role, rwId: 5);
      case UserRole.ketuaRt:
        return AppUser(username: username, role: role, rwId: 5, rtId: 2);
      default:
        return AppUser(username: username, role: role);
    }
  }
}
