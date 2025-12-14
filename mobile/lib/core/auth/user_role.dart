/// Supported user roles for the dummy authentication flow.
enum UserRole {
  admin,
  ketuaRw,
  ketuaRt,
  sekretaris,
  bendahara,
  warga;

  static UserRole fromUsername(String username) {
    switch (username.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'ketuarw':
        return UserRole.ketuaRw;
      case 'ketuart':
        return UserRole.ketuaRt;
      case 'sekretaris':
        return UserRole.sekretaris;
      case 'bendahara':
        return UserRole.bendahara;
      default:
        return UserRole.warga;
    }
  }
}

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.ketuaRw:
        return 'Ketua RW';
      case UserRole.ketuaRt:
        return 'Ketua RT';
      case UserRole.sekretaris:
        return 'Sekretaris';
      case UserRole.bendahara:
        return 'Bendahara';
      case UserRole.warga:
        return 'Warga';
    }
  }
}
