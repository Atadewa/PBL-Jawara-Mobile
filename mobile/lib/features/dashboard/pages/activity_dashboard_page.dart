import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/activity_stat_card.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/activity_category_legend.dart';
import '../widgets/person_ranking_item.dart';

class ActivityDashboardPage extends StatefulWidget {
  const ActivityDashboardPage({Key? key}) : super(key: key);

  @override
  State<ActivityDashboardPage> createState() => _ActivityDashboardPageState();
}

class _ActivityDashboardPageState extends State<ActivityDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load activity data when page opens
    Future.microtask(() => context.read<ActivityProvider>().loadActivity());
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.startsWith('0xFF')) {
      return Color(int.parse(hexColor));
    }
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          // Error state
          if (provider.isError) {
            return Column(
              children: [
                const DashboardHeader(
                  title: 'Dashboard Kegiatan',
                  subtitle: 'Laporan Kegiatan RT/RW',
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 56,
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error ?? 'Terjadi kesalahan',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadActivity();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EE7B7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Loading state
          if (provider.isLoading) {
            return Column(
              children: [
                const DashboardHeader(
                  title: 'Dashboard Kegiatan',
                  subtitle: 'Laporan Kegiatan RT/RW',
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6EE7B7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final data = provider.data;

          // Loaded state
          return RefreshIndicator(
            onRefresh: () => provider.refreshActivity(),
            color: const Color(0xFF6EE7B7),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const DashboardHeader(
                    title: 'Dashboard Kegiatan',
                    subtitle: 'Laporan Kegiatan RT/RW',
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Kegiatan Tahun Ini Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              top: BorderSide(
                                color: Color(0xFF6EE7B7),
                                width: 3,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6EE7B7,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF6EE7B7),
                                      size: 24,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    data?.summary.totalActivities ?? '0',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Total Kegiatan Tahun Ini',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                  fontFamily: 'Arimo',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary stat cards (3 columns: Selesai, Hari Ini, Mendatang)
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                          children: [
                            ActivityStatCard(
                              label: 'Selesai',
                              value: data?.summary.completed ?? '0',
                              icon: Icons.check_circle_outline,
                              color: const Color(0xFF94A3B8),
                              borderColor: const Color(0xFF94A3B8),
                            ),
                            ActivityStatCard(
                              label: 'Hari Ini',
                              value: data?.summary.today ?? '0',
                              icon: Icons.event_available,
                              color: const Color(0xFF6EE7B7),
                              borderColor: const Color(0xFF6EE7B7),
                            ),
                            ActivityStatCard(
                              label: 'Mendatang',
                              value: data?.summary.upcoming ?? '0',
                              icon: Icons.schedule,
                              color: const Color(0xFFFACC15),
                              borderColor: const Color(0xFFFACC15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Categories section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kegiatan per Kategori',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Arimo',
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Pie chart placeholder
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pie_chart,
                                        size: 48,
                                        color: const Color(
                                          0xFF94A3B8,
                                        ).withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pie Chart Placeholder',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(
                                            0xFF94A3B8,
                                          ).withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Category legend
                              if (data?.categories != null)
                                ActivityCategoryLegend(
                                  categories: data!.categories,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Monthly chart
                        ChartPlaceholder(
                          title: 'Kegiatan per Bulan',
                          height: 250,
                        ),
                        const SizedBox(height: 32),
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
}
