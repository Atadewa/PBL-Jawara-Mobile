/// Helper function to get readable role label
/// Priority: admin > ketua_rw > ketua_rt > sekretaris > bendahara > warga
String getRoleLabel(List<String> roles) {
  if (roles.isEmpty) return 'Warga';

  // Priority order
  const rolePriority = {
    'admin': 1,
    'ketua_rw': 2,
    'ketua_rt': 3,
    'sekretaris': 4,
    'bendahara': 5,
    'warga': 6,
  };

  const roleLabels = {
    'admin': 'Admin',
    'ketua_rw': 'Ketua RW',
    'ketua_rt': 'Ketua RT',
    'sekretaris': 'Sekretaris',
    'bendahara': 'Bendahara',
    'warga': 'Warga',
  };

  // Sort roles by priority
  final sortedRoles = List<String>.from(roles)
    ..sort((a, b) {
      final priorityA = rolePriority[a.toLowerCase()] ?? 999;
      final priorityB = rolePriority[b.toLowerCase()] ?? 999;
      return priorityA.compareTo(priorityB);
    });

  // Return the highest priority role label
  final topRole = sortedRoles.first.toLowerCase();
  return roleLabels[topRole] ?? 'Warga';
}

/// Get scope text for display
/// Returns formatted text like "RW 5" or "RW 5 • RT 2" or "Semua wilayah"
String getScopeText(Map<String, dynamic> scope) {
  final mode = scope['mode'] as String?;
  final rwValue = scope['rw'];
  final rtValue = scope['rt'];

  // Safely convert to string for display
  final rw = rwValue?.toString() ?? '';
  final rt = rtValue?.toString() ?? '';

  if (mode == 'all') {
    return 'Akses: Semua wilayah';
  }

  if (mode == 'rw') {
    final rwText = 'RW $rw';
    if (rtValue != null) {
      return '$rwText • RT $rt';
    }
    return rwText;
  }

  if (mode == 'rt') {
    return 'RW $rw • RT $rt';
  }

  return 'RW $rw • RT $rt';
}
