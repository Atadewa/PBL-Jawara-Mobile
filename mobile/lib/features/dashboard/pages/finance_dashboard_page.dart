import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/category_legend.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({Key? key}) : super(key: key);

  @override
  State<FinanceDashboardPage> createState() => _FinanceDashboardPageState();
}

class _FinanceDashboardPageState extends State<FinanceDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load finance data when page opens
    Future.microtask(() => context.read<FinanceProvider>().loadFinance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, _) {
          // Error state
          if (provider.isError) {
            return Column(
              children: [
                const DashboardHeader(
                  title: 'Dashboard Keuangan',
                  subtitle: 'Kelola keuangan komunitas Anda',
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
                            provider.loadFinance();
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
                  title: 'Dashboard Keuangan',
                  subtitle: 'Kelola keuangan komunitas Anda',
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
            onRefresh: () => provider.refreshFinance(),
            color: const Color(0xFF6EE7B7),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const DashboardHeader(
                    title: 'Dashboard Keuangan',
                    subtitle: 'Kelola keuangan komunitas Anda',
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards (horizontal responsive layout)
                        Row(
                          children: [
                            // Income Card
                            Expanded(
                              child: FinanceSummaryCard(
                                label: 'Pemasukan',
                                value: _formatCurrency(
                                  data?.summary.totalIncome,
                                ),
                                icon: Icons.trending_up_rounded,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Expense Card
                            Expanded(
                              child: FinanceSummaryCard(
                                label: 'Pengeluaran',
                                value: _formatCurrency(
                                  data?.summary.totalExpense,
                                ),
                                icon: Icons.trending_down_rounded,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Balance Card
                            Expanded(
                              child: FinanceSummaryCard(
                                label: 'Transaksi',
                                value: '0',
                                icon: Icons.receipt_long_rounded,
                                color: const Color(0xFF6EE7B7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Income Per Month Chart
                        ChartPlaceholder(
                          title: 'Pemasukan per Bulan',
                          height: 250,
                        ),
                        const SizedBox(height: 24),

                        // Expense Per Month Chart
                        ChartPlaceholder(
                          title: 'Pengeluaran per Bulan',
                          height: 250,
                        ),
                        const SizedBox(height: 24),

                        // Income Categories
                        if (data?.incomeCategories != null)
                          CategoryLegend(
                            title: 'Pemasukan Berdasarkan Kategori',
                            categories: data!.incomeCategories,
                          ),
                        const SizedBox(height: 24),

                        // Expense Categories
                        if (data?.expenseCategories != null)
                          CategoryLegend(
                            title: 'Pengeluaran Berdasarkan Kategori',
                            categories: data!.expenseCategories,
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

  String _formatCurrency(String? value) {
    if (value == null) return 'Rp 0';

    final amount = int.tryParse(value) ?? 0;
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp $amount';
  }
}
