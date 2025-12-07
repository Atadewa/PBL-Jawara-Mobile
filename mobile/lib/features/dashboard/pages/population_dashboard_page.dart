import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/population_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/population_stat_card.dart';
import '../widgets/population_chart_card.dart';

class PopulationDashboardPage extends StatefulWidget {
  const PopulationDashboardPage({super.key});

  @override
  State<PopulationDashboardPage> createState() =>
      _PopulationDashboardPageState();
}

class _PopulationDashboardPageState extends State<PopulationDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load population data saat screen dibuka
    Future.microtask(() {
      context.read<PopulationProvider>().loadPopulationDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<PopulationProvider>(
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
                      provider.refreshPopulationDashboard();
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
            onRefresh: () => provider.refreshPopulationDashboard(),
            color: const Color(0xFF6EE7B7),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  DashboardHeader(
                    title: 'Dashboard Kependudukan',
                    subtitle: 'Statistik Penduduk RT/RW',
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards (2 columns)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                          children: [
                            PopulationStatCard(
                              title: 'Total Keluarga',
                              value: data.summary.totalFamilies,
                              icon: Icons.home,
                            ),
                            PopulationStatCard(
                              title: 'Total Penduduk',
                              value: data.summary.totalResidents,
                              icon: Icons.people,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Analysis section
                        Text(
                          'Analisis Demografi',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),

                        // Status Penduduk
                        PopulationChartCard(analysis: data.residentStatus),
                        const SizedBox(height: 16),

                        // Jenis Kelamin
                        PopulationChartCard(analysis: data.gender),
                        const SizedBox(height: 16),

                        // Pendidikan
                        PopulationChartCard(analysis: data.education),

                        const SizedBox(height: 24),

                        // Footer
                        Center(
                          child: Text(
                            'Data terakhir diperbarui: ${data.lastUpdated.day}/${data.lastUpdated.month}/${data.lastUpdated.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontFamily: 'Arimo',
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
}
