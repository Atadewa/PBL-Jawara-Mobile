import 'package:flutter/material.dart';
import '../models/income_model.dart';

class IncomeDetailsPage extends StatelessWidget {
  final Income income;

  const IncomeDetailsPage({required this.income});

  static const _bgColor = Color(0xFFF8FAFC);
  static const _headerGradient = [Color(0xFF6EE7B7), Color(0xFF34D399)];
  static const _primaryBorder = Color(0xFF6EE7B7);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF94A3B8);

  TextStyle get _labelStyle => const TextStyle(
        color: _textMuted,
        fontSize: 16,
        fontFamily: 'Arimo',
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  TextStyle get _valueStyle => const TextStyle(
        color: _textPrimary,
        fontSize: 16,
        fontFamily: 'Arimo',
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  TextStyle get _titleValueStyle => const TextStyle(
        color: _textPrimary,
        fontSize: 18,
        fontFamily: 'Arimo',
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
          child: Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 10,
                  offset: Offset(0, 8),
                  spreadRadius: -6,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 25,
                  offset: Offset(0, 20),
                  spreadRadius: -5,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Header (inside card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.5, 0.0),
                      end: Alignment(0.5, 1.0),
                      colors: _headerGradient,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detail Pemasukan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Detail card
                        Container(
                          width: double.infinity,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 3.48,
                                color: _primaryBorder,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama Pemasukan', style: _labelStyle),
                                const SizedBox(height: 4),
                                Text(income.title, style: _titleValueStyle),
                                const SizedBox(height: 16),

                                Text('Kategori', style: _labelStyle),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: income.categoryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999999),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      income.category,
                                      style: TextStyle(
                                        color: income.categoryTextColor,
                                        fontSize: 16,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text('Nominal', style: _labelStyle),
                                const SizedBox(height: 4),
                                Text(
                                  income.amount,
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text('Tanggal', style: _labelStyle),
                                const SizedBox(height: 4),
                                Text(income.date, style: _valueStyle),
                                const SizedBox(height: 16),

                                if ((income.description ?? '').trim().isNotEmpty) ...[
                                  Text('Deskripsi', style: _labelStyle),
                                  const SizedBox(height: 4),
                                  Text(income.description!.trim(), style: _valueStyle),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bukti Pemasukan
                        const Text(
                          'Bukti Pemasukan',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 256,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            'https://placehold.co/271x256',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 48,
                                  color: _textMuted,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Edit button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF6EE7B7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                  spreadRadius: -4,
                                ),
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 15,
                                  offset: Offset(0, 10),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Edit Pemasukan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
