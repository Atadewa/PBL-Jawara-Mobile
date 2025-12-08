import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../pages/finance_dashboard_page.dart';
import '../pages/activity_dashboard_page.dart';
import '../pages/population_dashboard_page.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/quick_menu.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data saat screen dibuka
    Future.microtask(() {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
              ),
            );
          }

          if (provider.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.refreshDashboard();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EE7B7),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!provider.isLoaded || provider.data == null) {
            return const Center(child: Text('Tidak ada data'));
          }

          final data = provider.data!;

          return RefreshIndicator(
            onRefresh: () => provider.refreshDashboard(),
            color: const Color(0xFF6EE7B7),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header gradient
                  DashboardHeader(
                    title: 'Selamat Datang, Pengurus RT/RW',
                    subtitle: data.userLocation,
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat cards grid (2 columns)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            for (var widget in data.widgets)
                              StatCardWidget(
                                label: widget.title,
                                value: widget.value,
                                borderColor: widget.color ?? '0xFF6EE7B7',
                                icon: _getIconData(widget.icon ?? 'info'),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Action cards section
                        Text(
                          'Dashboard',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        // Dashboard Keuangan
                        ActionCardWidget(
                          title: 'Dashboard Keuangan',
                          description: 'Lihat laporan keuangan lengkap',
                          icon: Icons.attach_money,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FinanceDashboardPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Dashboard Kegiatan
                        ActionCardWidget(
                          title: 'Dashboard Kegiatan',
                          description: 'Lihat statistik kegiatan RT/RW',
                          icon: Icons.calendar_today,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ActivityDashboardPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Dashboard Kependudukan
                        ActionCardWidget(
                          title: 'Dashboard Kependudukan',
                          description: 'Lihat data demografi warga',
                          icon: Icons.people,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PopulationDashboardPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Quick menu section
                        Text(
                          'Menu Cepat',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),

                        // Menu grid (4 items per row)
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                          children: [
                            QuickMenuWidget(
                              label: 'Data Warga',
                              icon: Icons.people,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data Warga')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Rumah',
                              icon: Icons.home,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Rumah')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Tagihan',
                              icon: Icons.receipt,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tagihan')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Kegiatan',
                              icon: Icons.event,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Kegiatan')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Marketplace',
                              icon: Icons.shopping_bag,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Marketplace')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Laporan',
                              icon: Icons.assignment,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Laporan')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Pengguna',
                              icon: Icons.person,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pengguna')),
                                );
                              },
                            ),
                            QuickMenuWidget(
                              label: 'Transfer',
                              icon: Icons.send,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transfer')),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Footer
                        Center(
                          child: Text(
                            'Aplikasi Manajemen RT/RW',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Convert icon name string to IconData
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'people':
        return Icons.people;
      case 'home':
        return Icons.home;
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'attach_money':
      case 'money':
        return Icons.attach_money;
      case 'alert':
      case 'warning':
        return Icons.warning_amber;
      case 'calendar':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }
}
