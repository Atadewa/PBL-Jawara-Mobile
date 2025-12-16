import 'package:flutter/material.dart';
import '../../data/models/expense_item.dart';
import '../../data/models/expense_category.dart';
import '../../data/services/expense_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../../core/routes/app_routes.dart';
import 'detail_pengeluaran_page.dart';

/// Halaman Daftar Pengeluaran
class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final ExpenseService _expenseService = ExpenseService();
  List<ExpenseItem> _expenses = [];
  List<ExpenseItem> _filteredExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter state
  List<ExpenseCategory> _selectedCategories = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final expenses = await _expenseService.fetchExpenses();
      setState(() {
        _expenses = expenses;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<ExpenseItem> filtered = List.from(_expenses);

    // Filter by categories
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((expense) {
        return _selectedCategories.contains(expense.category);
      }).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((expense) {
        return expense.date.isAfter(
          _startDate!.subtract(const Duration(days: 1)),
        );
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((expense) {
        return expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredExpenses = filtered;
      _isFiltered =
          _selectedCategories.isNotEmpty ||
          _startDate != null ||
          _endDate != null;
    });
  }

  void _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCategories: _selectedCategories,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategories = result['categories'] as List<ExpenseCategory>;
        _startDate = result['startDate'] as DateTime?;
        _endDate = result['endDate'] as DateTime?;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories = [];
      _startDate = null;
      _endDate = null;
      _isFiltered = false;
    });
    _applyFilters();
  }

  void _navigateToDetail(ExpenseItem expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPengeluaranPage(expenseId: expense.id),
      ),
    );

    // Reload jika ada perubahan (edit)
    if (result == true && mounted) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Daftar Pengeluaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isFiltered
                                  ? Icons.filter_alt
                                  : Icons.filter_list,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _showFilterBottomSheet,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const Text(
                      'Kelola semua pengeluaran lingkungan',
                      style: TextStyle(
                        color: Color(0xE5FFFEFE),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
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
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(36410900),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 50,
              offset: Offset(0, 25),
              spreadRadius: -12,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 32),
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.addPengeluaran,
            );

            // Reload list if expense was added successfully
            if (result == true) {
              _loadExpenses();
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExpenses,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_expenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan pengeluaran pertama Anda',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Menampilkan filtered atau all expenses
    final displayExpenses = _isFiltered ? _filteredExpenses : _expenses;

    if (displayExpenses.isEmpty && _isFiltered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada hasil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tidak ada pengeluaran yang sesuai filter',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Hapus Filter'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter chips jika ada filter aktif
        if (_isFiltered)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Category chips
                      ..._selectedCategories.map((category) {
                        return Chip(
                          label: Text(category.label),
                          backgroundColor: category.backgroundColor,
                          labelStyle: TextStyle(
                            color: category.textColor,
                            fontSize: 12,
                            fontFamily: 'Arimo',
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: category.textColor,
                          ),
                          onDeleted: () {
                            setState(() {
                              _selectedCategories.remove(category);
                            });
                            _applyFilters();
                          },
                        );
                      }),
                      // Date range chip
                      if (_startDate != null || _endDate != null)
                        Chip(
                          label: Text(
                            _startDate != null && _endDate != null
                                ? '${_formatDateShort(_startDate!)} - ${_formatDateShort(_endDate!)}'
                                : _startDate != null
                                ? 'Dari ${_formatDateShort(_startDate!)}'
                                : 'Sampai ${_formatDateShort(_endDate!)}',
                          ),
                          backgroundColor: const Color(0xFFE0F2FE),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0369A1),
                            fontSize: 12,
                            fontFamily: 'Arimo',
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF0369A1),
                          ),
                          onDeleted: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                            _applyFilters();
                          },
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Hapus Semua',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadExpenses,
            color: const Color(0xFF10B981),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: displayExpenses.length,
              itemBuilder: (context, index) {
                final expense = displayExpenses[index];
                return ExpenseCard(
                  expense: expense,
                  onTap: () => _navigateToDetail(expense),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
