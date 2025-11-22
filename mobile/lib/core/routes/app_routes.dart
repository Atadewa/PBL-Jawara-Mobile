import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/pages/home_page.dart';

/// Centralized route management
/// Memudahkan maintenance dan menghindari hardcoded route strings
class AppRoutes {
  // Route names
  static const String login = '/';
  static const String home = '/home';

  // TODO: Add more routes as needed
  // static const String marketplace = '/marketplace';
  // static const String kegiatan = '/kegiatan';
  // static const String profil = '/profil';

  /// Route definitions
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    // Add more routes here when needed
  };

  /// Initial route
  static String get initialRoute => login;
}
