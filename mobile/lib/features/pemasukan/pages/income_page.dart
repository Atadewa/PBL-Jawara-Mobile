import 'package:flutter/material.dart';
import '../models/income_model.dart';
import '../widgets/income_item.dart';
import '../widgets/add_income_button.dart';
import 'add_income_page.dart';
import 'income_details_page.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<Income> _incomes = [
    Income(
      title: 'Donasi HUT RI dari Pemda',
      category: 'Dana Bantuan Pemerintah',
      amount: 'Rp 5.000.000',
      date: '15 Agustus 2025',
      categoryColor: Color(0xFFDBEAFE),
      categoryTextColor: Color(0xFF1347E5),
      description:
          'Dana bantuan dari pemerintah daerah untuk mendukung pelaksanaan kegiatan peringatan HUT RI ke-80 di lingkungan RT 01 / RW 05. Dana digunakan untuk keperluan dekorasi, doorprize, dan konsumsi.',
    ),
    Income(
      title: 'Sumbangan Warga untuk Renovasi',
      category: 'Sumbangan Swadaya',
      amount: 'Rp 2.500.000',
      date: '10 November 2025',
      categoryColor: Color(0xFFFFEDD4),
      categoryTextColor: Color(0xFFC93400),
    ),
    Income(
      title: 'Hasil Usaha Warung Kampung',
      category: 'Hasil Usaha Kampung',
      amount: 'Rp 1.200.000',
      date: '1 November 2025',
      categoryColor: Color(0xFFD0FAE5),
      categoryTextColor: Color(0xFF007955),
    ),
    Income(
      title: 'Donasi dari Alumni RT',
      category: 'Donasi',
      amount: 'Rp 3.000.000',
      date: '20 Oktober 2025',
      categoryColor: Color(0xFFF3E8FF),
      categoryTextColor: Color(0xFF8200DA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Hilangkan background abu-abu
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pemasukan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Main Card (menyatu dengan background putih)
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: AddIncomeButton(
                        onPressed: () async {
                          final newIncome = await Navigator.push<Income>(
                            context,
                            MaterialPageRoute(builder: (_) => AddIncomePage()),
                          );
                          if (newIncome != null) {
                            setState(() => _incomes.insert(0, newIncome));
                          }
                        },
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _incomes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: IncomeItem(
                              income: _incomes[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IncomeDetailsPage(
                                      income: _incomes[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
