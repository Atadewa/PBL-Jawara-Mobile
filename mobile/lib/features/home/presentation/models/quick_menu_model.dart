import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';

class QuickMenuModel {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final Set<UserRole> allowedRoles;

  const QuickMenuModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.allowedRoles,
  });
}
