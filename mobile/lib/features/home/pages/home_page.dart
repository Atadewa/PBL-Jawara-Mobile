import 'package:flutter/material.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/simple_stat_card.dart';
import '../widgets/dashboard_button.dart';
import '../widgets/quick_menu_item.dart';
import '../models/home_stats.dart';
import '../models/user_info.dart';
import '../services/home_service.dart';

/// Halaman Home/Dashboard
/// Menampilkan statistik utama, tombol dashboard, dan menu cepat
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _homeService = HomeService();
  bool _isLoading = true;
  UserInfo? _userInfo;
  HomeStats? _stats;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data dari API
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _homeService.loadHomeData();

      if (!mounted) return;

      setState(() {
        _userInfo = data['userInfo'] as UserInfo;
        _stats = data['stats'] as HomeStats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan gradient hijau
                    _buildHeader(),

                    // Content dengan padding
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 4 Simple Stats Cards
                          _buildStatsCards(),
                          const SizedBox(height: 24),

                          // 3 Dashboard Buttons
                          _buildDashboardButtons(),
                          const SizedBox(height: 24),

                          // Menu Cepat
                          _buildQuickMenu(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Build header section dengan gradient hijau
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF10B981), const Color(0xFF10B981)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang,',
                style: TextStyle(
                  color: Color(0xE5FFFEFE),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userInfo?.role ?? 'Pengurus RT/RW',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userInfo?.rtRw ?? 'RT 01 / RW 05',
                style: const TextStyle(
                  color: Color(0xE5FFFEFE),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build 4 simple stats cards (2x2 grid)
  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        SimpleStatCard(
          label: 'Total Warga',
          value: _stats?.totalWarga.toString() ?? '0',
          topBorderColor: const Color(0xFF10B981),
          onTap: () => _handleCardTap('Total Warga'),
        ),
        SimpleStatCard(
          label: 'Total Keluarga',
          value: _stats?.totalKeluarga.toString() ?? '0',
          topBorderColor: const Color(0xFF10B981),
          onTap: () => _handleCardTap('Total Keluarga'),
        ),
        SimpleStatCard(
          label: 'Pemasukan',
          value: _stats?.pemasukan ?? 'Rp 0',
          topBorderColor: const Color(0xFF10B981),
          onTap: () => _handleCardTap('Pemasukan'),
        ),
        SimpleStatCard(
          label: 'Pengeluaran',
          value: _stats?.pengeluaran ?? 'Rp 0',
          topBorderColor: const Color(0xFFEF4444),
          onTap: () => _handleCardTap('Pengeluaran'),
        ),
      ],
    );
  }

  /// Build 3 dashboard buttons
  Widget _buildDashboardButtons() {
    return Column(
      children: [
        DashboardButton(
          title: 'Dashboard Keuangan',
          subtitle: 'Lihat laporan keuangan lengkap',
          icon: Icons.account_balance_wallet,
          onTap: () => _handleDashboardTap('Keuangan'),
        ),
        const SizedBox(height: 12),
        DashboardButton(
          title: 'Dashboard Kegiatan',
          subtitle: 'Lihat statistik kegiatan RT/RW',
          icon: Icons.event_note,
          onTap: () => _handleDashboardTap('Kegiatan'),
        ),
        const SizedBox(height: 12),
        DashboardButton(
          title: 'Dashboard Kependudukan',
          subtitle: 'Lihat data demografi warga',
          icon: Icons.people,
          onTap: () => _handleDashboardTap('Kependudukan'),
        ),
      ],
    );
  }

  /// Build menu cepat section
  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Cepat',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.80, // Adjusted to accommodate fixed height
            children: [
              QuickMenuItem(
                label: 'Verifikasi User',
                icon: Icons.person_add,
                onTap: () => _handleMenuTap('Verifikasi User'),
              ),
              QuickMenuItem(
                label: 'Rumah',
                icon: Icons.home,
                onTap: () => _handleMenuTap('Rumah'),
              ),
              QuickMenuItem(
                label: 'Aspirasi Warga',
                icon: Icons.feedback,
                onTap: () => _handleMenuTap('Aspirasi Warga'),
              ),
              QuickMenuItem(
                label: 'Log Aktivitas',
                icon: Icons.history,
                onTap: () => _handleMenuTap('Log Aktivitas'),
              ),
              QuickMenuItem(
                label: 'Pengeluaran',
                icon: Icons.trending_down,
                onTap: () => _handleMenuTap('Pengeluaran'),
              ),
              QuickMenuItem(
                label: 'Pemasukan',
                icon: Icons.trending_up,
                onTap: () => _handleMenuTap('Pemasukan'),
              ),
              QuickMenuItem(
                label: 'Laporan',
                icon: Icons.assignment,
                onTap: () => _handleMenuTap('Laporan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handle stat card tap
  void _handleCardTap(String label) {
    // TODO: Navigate to detail page
  }

  /// Handle dashboard button tap
  void _handleDashboardTap(String dashboard) {
    switch (dashboard) {
      case 'Keuangan':
        Navigator.pushNamed(context, AppRoutes.financeDashboard);
        break;
      case 'Kegiatan':
        Navigator.pushNamed(context, AppRoutes.activityDashboard);
        break;
      case 'Kependudukan':
        Navigator.pushNamed(context, AppRoutes.populationDashboard);
        break;
    }
  }

  /// Handle menu cepat tap
  void _handleMenuTap(String menu) {
    switch (menu) {
      case 'Pengeluaran':
        Navigator.pushNamed(context, AppRoutes.pengeluaran);
        break;
      case 'Kegiatan':
        Navigator.pushNamed(context, '/aktivitas-dan-broadcast');
        break;
      case 'Rumah':
        Navigator.pushNamed(context, '/data-rumah');
        break;
      default:
        // TODO: Navigate to other menu pages
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$menu - Coming soon')));
    if (menu == 'Pemasukan') {
      Navigator.of(context).pushNamed(AppRoutes.pemasukan);
      return;
    }

    // fallback / other menu navigation
    // TODO: Navigate to other menu pages
    if (menu == 'Pengeluaran') {
      Navigator.pushNamed(context, AppRoutes.pengeluaran);
    } else if (menu == 'Log Aktivitas') {
      Navigator.pushNamed(context, AppRoutes.logAktivitas);
    } else if (menu == 'Rumah') {
      Navigator.pushNamed(context, AppRoutes.daftarRumah);
    } else if (menu == 'Kegiatan') {
      Navigator.pushNamed(context, AppRoutes.aktivitasDanBroadcast);
    } else if (menu == 'Marketplace') {
      Navigator.pushNamed(context, AppRoutes.marketplace);
    } else if (menu == 'Laporan') {
      Navigator.pushNamed(context, AppRoutes.laporan);
    } else if (menu == 'Aspirasi Warga') {
      Navigator.pushNamed(context, AppRoutes.aspirasi);
    } else {
      // TODO: Navigate to other menu pages
    }
  }
}
