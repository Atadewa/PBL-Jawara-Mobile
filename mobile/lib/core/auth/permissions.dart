/// Permission helper for managing broadcast and event CRUD operations
///
/// Only ketua_rw, ketua_rt, and sekretaris can create, update, delete,
/// publish, and upload files for broadcasts and events.

/// Check if the user has permission to manage broadcasts and events
///
/// Returns true if user has any of these roles:
/// - admin
/// - ketua_rw
/// - ketua_rt
/// - sekretaris
///
/// All other roles (warga, bendahara, etc.) return false
bool canManageBroadcastAndEvent(List<String> roles) {
  if (roles.isEmpty) return false;

  const allowedRoles = ['admin', 'ketua_rw', 'ketua_rt', 'sekretaris'];

  // Check if user has any of the allowed roles
  return roles.any((role) => allowedRoles.contains(role.toLowerCase()));
}

/// Get user-friendly error message for permission denied
String getPermissionDeniedMessage() {
  return 'Kamu tidak punya akses untuk aksi ini';
}
