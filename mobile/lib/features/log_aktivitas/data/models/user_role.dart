import 'package:flutter/material.dart';

enum UserRole {
  admin('Admin', Color(0xFF6EE7B7)),
  ketuaRT('Ketua RT', Color(0xFF6EE7B7)),
  ketuaRW('Ketua RW', Color(0xFF6EE7B7)),
  bendahara('Bendahara', Color(0xFF6EE7B7)),
  sekretaris('Sekretaris', Color(0xFF6EE7B7)),
  warga('Warga', Color(0xFF6EE7B7));

  final String displayName;
  final Color color;

  const UserRole(this.displayName, this.color);

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'ketua rt':
      case 'ketuart':
        return UserRole.ketuaRT;
      case 'ketua rw':
      case 'ketuarw':
        return UserRole.ketuaRW;
      case 'bendahara':
        return UserRole.bendahara;
      case 'sekretaris':
        return UserRole.sekretaris;
      case 'warga':
        return UserRole.warga;
      default:
        return UserRole.warga;
    }
  }
}
