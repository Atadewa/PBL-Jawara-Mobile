import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../../features/pengeluaran/presentation/pages/pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/add_pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/detail_pengeluaran_page.dart';
import '../../../features/pengeluaran/presentation/pages/edit_pengeluaran_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/marketplace/presentation/pages/my_products_page.dart';
import '../../features/marketplace/presentation/pages/my_purchases_page.dart';

/// Centralized route management
/// Memudahkan maintenance dan menghindari hardcoded route strings
class AppRoutes {
  // Initial route
  static const String initialRoute = login;

  // Route names
  static const String login = '/';
  static const String home = '/home';
  static const String pengeluaran = '/pengeluaran';
  static const String addPengeluaran = '/pengeluaran/add';
  static const String detailPengeluaran = '/pengeluaran/detail';
  static const String editPengeluaran = '/pengeluaran/edit';

  // Marketplace routes
  static const String marketplace = '/marketplace';
  static const String myProducts = '/marketplace/my-products';
  static const String myPurchases = '/marketplace/my-purchases';

  // TODO: Add more routes as needed
  // static const String kegiatan = '/kegiatan';
  // static const String profil = '/profil';

  /// Route definitions
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    pengeluaran: (context) => const PengeluaranPage(),
    addPengeluaran: (context) => const AddPengeluaranPage(),
    marketplace: (context) => const MarketplacePage(),
    myProducts: (context) => const MyProductsPage(),
    myPurchases: (context) => const MyPurchasesPage(),
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
      default:
        return null;
    }
  }
}
