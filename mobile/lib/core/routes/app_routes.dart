import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/dashboard/pages/finance_dashboard_page.dart';
import '../../features/dashboard/pages/activity_dashboard_page.dart';
import '../../features/dashboard/pages/population_dashboard_page.dart';
import '../../features/pemasukan/pages/income_page.dart';
import '../../../features/pengeluaran/presentation/pages/pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/add_pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/detail_pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/edit_pengeluaran_page.dart';
import '../../../features/log_aktivitas/presentation/pages/log_aktivitas_page.dart';
import '../../features/data_rumah_dan_warga/pages/daftar_rumah_page.dart';
import '../../features/data_rumah_dan_warga/pages/detail_rumah_page.dart';
import '../../features/data_rumah_dan_warga/pages/edit_rumah_page.dart';
import '../../features/data_rumah_dan_warga/pages/daftar_keluarga_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/aktivitas_dan_broadcast_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/detail_kegiatan_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/edit_kegiatan_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/add_kegiatan_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/broadcast_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/broadcast_detail_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/edit_broadcast_page.dart';
import '../../features/aktivitas_dan_broadcast/pages/add_broadcast_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/marketplace/presentation/pages/my_products_page.dart';
import '../../features/marketplace/presentation/pages/my_purchases_page.dart';
import '../../features/laporan/pages/laporan_page.dart';
import '../../features/aspirasi/presentation/pages/aspirasi_page.dart';

/// Centralized route management
/// Memudahkan maintenance dan menghindari hardcoded route strings
class AppRoutes {
  // Initial route
  static const String initialRoute = login;

  // Route names
  static const String login = '/';
  static const String home = '/home';
  static const String pemasukan = '/pemasukan';
  static const String pengeluaran = '/pengeluaran';
  static const String addPengeluaran = '/pengeluaran/add';
  static const String detailPengeluaran = '/pengeluaran/detail';
  static const String editPengeluaran = '/pengeluaran/edit';
  static const String logAktivitas = '/log-aktivitas';
  static const String daftarRumah = '/data-rumah';
  static const String detailRumah = '/data-rumah/detail';
  static const String editRumah = '/data-rumah/edit';
  static const String daftarKeluarga = '/data-rumah/keluarga';
  static const String aktivitasDanBroadcast = '/aktivitas-dan-broadcast';
  static const String addKegiatan = '/aktivitas-dan-broadcast/add';
  static const String detailKegiatan = '/aktivitas-dan-broadcast/detail';
  static const String editKegiatan = '/aktivitas-dan-broadcast/edit';
  static const String broadcast = '/aktivitas-dan-broadcast/broadcast';
  static const String broadcastDetail =
      '/aktivitas-dan-broadcast/broadcast/detail';
  static const String editBroadcast = '/aktivitas-dan-broadcast/broadcast/edit';
  static const String addBroadcast = '/aktivitas-dan-broadcast/broadcast/add';

  // Marketplace routes
  static const String marketplace = '/marketplace';
  static const String myProducts = '/marketplace/my-products';
  static const String myPurchases = '/marketplace/my-purchases';

  // Laporan route
  static const String laporan = '/laporan';

  // Dashboard routes
  static const String financeDashboard = '/dashboard/finance';
  static const String activityDashboard = '/dashboard/activity';
  static const String populationDashboard = '/dashboard/population';

  // Aspirasi routes
  static const String aspirasi = '/aspirasi';

  // TODO: Add more routes as needed
  // static const String kegiatan = '/kegiatan';
  // static const String profil = '/profil';

  /// Route definitions
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    pemasukan: (context) => IncomePage(),
    pengeluaran: (context) => const PengeluaranPage(),
    addPengeluaran: (context) => const AddPengeluaranPage(),
    financeDashboard: (context) => const FinanceDashboardPage(),
    activityDashboard: (context) => const ActivityDashboardPage(),
    populationDashboard: (context) => const PopulationDashboardPage(),
    logAktivitas: (context) => const LogAktivitasPage(),
    daftarRumah: (context) => const DaftarRumahPage(),
    aktivitasDanBroadcast: (context) => const AktivitasDanBroadcastPage(),
    marketplace: (context) => const MarketplacePage(),
    myProducts: (context) => const MyProductsPage(),
    myPurchases: (context) => const MyPurchasesPage(),
    laporan: (context) => const LaporanPage(),
    aspirasi: (context) => const AspirasiPage(),
    // Add more routes here when needed
  };

  /// Route generator for dynamic routes with arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case detailPengeluaran:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DetailPengeluaranPage(expenseId: expenseId),
        );
      case editPengeluaran:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditPengeluaranPage(expenseId: expenseId),
        );
      case detailRumah:
        final rumah = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => DetailRumahPage(rumah: rumah as dynamic),
        );
      case editRumah:
        final rumah = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => EditRumahPage(rumah: rumah as dynamic),
        );
      case daftarKeluarga:
        final rumah = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => DaftarKeluargaPage(rumah: rumah as dynamic),
        );
      case detailKegiatan:
        final kegiatanId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DetailKegiatanPage(kegiatanId: kegiatanId),
        );
      case editKegiatan:
        final kegiatanId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditKegiatanPage(kegiatanId: kegiatanId),
        );
      case addKegiatan:
        return MaterialPageRoute(builder: (_) => const AddKegiatanPage());
      case broadcast:
        return MaterialPageRoute(builder: (_) => const BroadcastPage());
      case broadcastDetail:
        final broadcastId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BroadcastDetailPage(broadcastId: broadcastId),
        );
      case editBroadcast:
        final broadcastId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditBroadcastPage(broadcastId: broadcastId),
        );
      case addBroadcast:
        return MaterialPageRoute(builder: (_) => const AddBroadcastPage());
      default:
        return null;
    }
  }
}
