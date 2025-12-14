import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/routes/app_routes.dart';
import '../models/quick_menu_model.dart';

/// Central registry to manage which quick menu appears for each role.
/// Names are kept identical to the original Menu Cepat items.
final List<QuickMenuModel> quickMenus = [
  QuickMenuModel(
    id: 'verifikasi_user',
    title: 'Verifikasi User',
    icon: Icons.person_add,
    route: AppRoutes.verifikasiWarga,
    allowedRoles: {
      UserRole.admin,
      UserRole.ketuaRw,
    },
  ),
  QuickMenuModel(
    id: 'rumah',
    title: 'Rumah',
    icon: Icons.home,
    route: AppRoutes.daftarRumah,
    allowedRoles: {
      UserRole.admin,
      UserRole.ketuaRw,
      UserRole.ketuaRt,
      UserRole.sekretaris,
      UserRole.bendahara,
      UserRole.warga,
    },
  ),
  QuickMenuModel(
    id: 'aspirasi_warga',
    title: 'Aspirasi Warga',
    icon: Icons.feedback,
    route: AppRoutes.aspirasi,
    allowedRoles: {
      UserRole.admin,
      UserRole.ketuaRw,
      UserRole.ketuaRt,
      UserRole.sekretaris,
      UserRole.warga,
    },
  ),
  QuickMenuModel(
    id: 'log_aktivitas',
    title: 'Log Aktivitas',
    icon: Icons.history,
    route: AppRoutes.logAktivitas,
    allowedRoles: {
      UserRole.admin,
    },
  ),
  QuickMenuModel(
    id: 'pengeluaran',
    title: 'Pengeluaran',
    icon: Icons.trending_down,
    route: AppRoutes.pengeluaran,
    allowedRoles: {
      UserRole.admin,
      UserRole.bendahara,
      UserRole.ketuaRt,
      UserRole.ketuaRw,
    },
  ),
  QuickMenuModel(
    id: 'pemasukan',
    title: 'Pemasukan',
    icon: Icons.trending_up,
    route: AppRoutes.pemasukan,
    allowedRoles: {
      UserRole.admin,
      UserRole.bendahara,
      UserRole.ketuaRw,
      UserRole.ketuaRt,
    },
  ),
  QuickMenuModel(
    id: 'laporan',
    title: 'Laporan',
    icon: Icons.assignment,
    route: AppRoutes.laporan,
    allowedRoles: {
      UserRole.admin,
      UserRole.bendahara,
      UserRole.ketuaRw,
      UserRole.ketuaRt,
    },
  ),
];

List<QuickMenuModel> getQuickMenusForRole(UserRole role) {
  return quickMenus.where((menu) => menu.allowedRoles.contains(role)).toList();
}
