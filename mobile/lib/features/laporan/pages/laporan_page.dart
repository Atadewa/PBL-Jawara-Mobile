import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedMonth = 'November';
  int selectedYear = 2024;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  // Dummy data transaksi
  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Iuran Bulanan - Pak Ahmad',
      'subtitle': 'Iuran Warga',
      'date': '20 November 2024',
      'amount': 50000,
      'type': 'pemasukan',
      'category': 'Pemasukan',
    },
    {
      'title': 'Pembelian Perlengkapan Kebersihan',
      'subtitle': 'Operasional',
      'date': '19 November 2024',
      'amount': 250000,
      'type': 'pengeluaran',
      'category': 'Pengeluaran',
    },
    {
      'title': 'Iuran Keamanan - Bu Siti',
      'subtitle': 'Iuran Keamanan',
      'date': '18 November 2024',
      'amount': 75000,
      'type': 'pemasukan',
      'category': 'Pemasukan',
    },
    {
      'title': 'Bayar Listrik Pos Ronda',
      'subtitle': 'Utilitas',
      'date': '17 November 2024',
      'amount': 180000,
      'type': 'pengeluaran',
      'category': 'Pengeluaran',
    },
    {
      'title': 'Donasi Acara 17 Agustus',
      'subtitle': 'Donasi',
      'date': '16 November 2024',
      'amount': 500000,
      'type': 'pemasukan',
      'category': 'Pemasukan',
    },
    {
      'title': 'Pembelian Bendera & Dekorasi',
      'subtitle': 'Acara',
      'date': '15 November 2024',
      'amount': 320000,
      'type': 'pengeluaran',
      'category': 'Pengeluaran',
    },
    {
      'title': 'Iuran Bulanan - Pak Budi',
      'subtitle': 'Iuran Warga',
      'date': '14 November 2024',
      'amount': 50000,
      'type': 'pemasukan',
      'category': 'Pemasukan',
    },
    {
      'title': 'Perbaikan Jalan RT',
      'subtitle': 'Infrastruktur',
      'date': '13 November 2024',
      'amount': 1500000,
      'type': 'pengeluaran',
      'category': 'Pengeluaran',
    },
    {
      'title': 'Iuran Sampah - Bu Ani',
      'subtitle': 'Iuran Sampah',
      'date': '12 November 2024',
      'amount': 30000,
      'type': 'pemasukan',
      'category': 'Pemasukan',
    },
    {
      'title': 'Honor Petugas Keamanan',
      'subtitle': 'Gaji',
      'date': '11 November 2024',
      'amount': 800000,
      'type': 'pengeluaran',
      'category': 'Pengeluaran',
    },
  ];

  // Hitung total pemasukan, pengeluaran, dan saldo
  double get totalPemasukan {
    return transactions
        .where((t) => t['type'] == 'pemasukan')
        .fold(0.0, (sum, t) => sum + t['amount']);
  }

  double get totalPengeluaran {
    return transactions
        .where((t) => t['type'] == 'pengeluaran')
        .fold(0.0, (sum, t) => sum + t['amount']);
  }

  double get saldo => totalPemasukan - totalPengeluaran;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildFilterSection(),
                    const SizedBox(height: 24),
                    _buildTransactionList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement cetak laporan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur cetak laporan akan segera hadir'),
            ),
          );
        },
        backgroundColor: const Color(0xFF6EE7B7),
        icon: const Icon(Icons.print, color: Colors.white),
        label: const Text(
          'Cetak Laporan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Laporan Keuangan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Laporan transaksi keuangan RT/RW',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Pemasukan',
            totalPemasukan,
            Icons.trending_up,
            const Color(0xFF10B981),
            Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Pengeluaran',
            totalPengeluaran,
            Icons.trending_down,
            const Color(0xFFEF4444),
            Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Saldo',
            saldo,
            Icons.account_balance_wallet,
            Colors.white,
            const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color backgroundColor,
    Color textColor,
  ) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: backgroundColor == Colors.white
            ? Border.all(color: const Color(0xFFE2E8F0))
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor == Colors.white
                  ? const Color(0xFFF1F5F9)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: backgroundColor == Colors.white ? textColor : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: backgroundColor == Colors.white
                  ? const Color(0xFF64748B)
                  : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter.format(amount),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Laporan',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bulan',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMonth = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahun',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [2022, 2023, 2024, 2025].map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedYear = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Transaksi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final bool isPemasukan = transaction['type'] == 'pemasukan';
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isPemasukan
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPemasukan
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPemasukan ? Icons.trending_up : Icons.trending_down,
                color: isPemasukan
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['title'],
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['subtitle'],
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['date'],
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPemasukan ? '+' : '-'}${formatter.format(transaction['amount'])}',
                  style: TextStyle(
                    color: isPemasukan
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPemasukan
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction['category'],
                    style: TextStyle(
                      color: isPemasukan
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
