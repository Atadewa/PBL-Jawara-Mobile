import 'package:flutter/material.dart';

import 'app_user.dart';

/// Global auth session using ValueNotifier to keep dependencies light.
class AuthSession {
  static final ValueNotifier<AppUser?> user = ValueNotifier<AppUser?>(null);

  static bool get isLoggedIn => user.value != null;

  static void logout() {
    user.value = null;
  }
}
