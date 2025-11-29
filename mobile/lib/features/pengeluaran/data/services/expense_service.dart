import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/expense_item.dart';
import '../models/expense_category.dart';

class ExpenseService {
  // TODO: Sesuaikan endpoint dengan API backend yang sebenarnya
  static const String _endpoint = '/pengeluaran';

  /// Fetch semua data pengeluaran
  /// 
  /// Returns list of [ExpenseItem]
  /// Throws exception jika request gagal
  Future<List<ExpenseItem>> fetchExpenses() async {
    try {
      if (ApiConfig.useDummyData) {
        // Dummy data untuk development (sesuai dengan design Figma)
        await Future.delayed(const Duration(milliseconds: 500));
        return _getDummyExpenses();
      }

      // API call real
      final url = Uri.parse('${ApiConfig.baseUrl}$_endpoint');
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExpenseItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

  /// Fetch detail pengeluaran berdasarkan ID
  /// 
  /// [id] - ID dari pengeluaran yang ingin diambil
  /// Returns [ExpenseItem]
  Future<ExpenseItem> fetchExpenseById(String id) async {
    try {
      if (ApiConfig.useDummyData) {
        await Future.delayed(const Duration(milliseconds: 300));
        final expenses = _getDummyExpenses();
        return expenses.firstWhere((expense) => expense.id == id);
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_endpoint/$id');
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return ExpenseItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load expense detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expense detail: $e');
    }
  }

  /// Create pengeluaran baru
  /// 
  /// [expenseData] - Data pengeluaran yang akan dibuat
  /// Returns created [ExpenseItem]
  Future<ExpenseItem> createExpense(Map<String, dynamic> expenseData) async {
    try {
      if (ApiConfig.useDummyData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return ExpenseItem.fromJson({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...expenseData,
        });
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_endpoint');
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode(expenseData),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ExpenseItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating expense: $e');
    }
  }

  /// Update pengeluaran
  /// 
  /// [id] - ID pengeluaran yang akan diupdate
  /// [expenseData] - Data pengeluaran yang baru
  /// Returns updated [ExpenseItem]
  Future<ExpenseItem> updateExpense(String id, Map<String, dynamic> expenseData) async {
    try {
      if (ApiConfig.useDummyData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return ExpenseItem.fromJson({
          'id': id,
          ...expenseData,
        });
      }

      final url = Uri.parse('${ApiConfig.baseUrl}$_endpoint/$id');
      final response = await http.put(
        url,
        headers: ApiConfig.defaultHeaders,
        body: json.encode(expenseData),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return ExpenseItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update expense: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating expense: $e');
    }
  }

  /// Dummy data untuk development (sesuai design Figma)
  List<ExpenseItem> _getDummyExpenses() {
    return [
      ExpenseItem(
        id: '1',
        title: 'Pembelian Alat Kebersihan',
        category: ExpenseCategory.keamananKebersihan,
        amount: 1500000,
        date: DateTime(2025, 11, 20),
        description: 'Pembelian sapu, pel, dan alat kebersihan lainnya',
      ),
      ExpenseItem(
        id: '2',
        title: 'Renovasi Pos Ronda',
        category: ExpenseCategory.pemeliharaanFasilitas,
        amount: 5000000,
        date: DateTime(2025, 11, 18),
        description: 'Perbaikan atap dan pengecatan pos ronda',
      ),
      ExpenseItem(
        id: '3',
        title: 'Perayaan HUT RI',
        category: ExpenseCategory.kegiatanWarga,
        amount: 3500000,
        date: DateTime(2025, 8, 17),
        description: 'Lomba 17an dan doorprize untuk warga',
      ),
      ExpenseItem(
        id: '4',
        title: 'Iuran Satpam Bulanan',
        category: ExpenseCategory.keamananKebersihan,
        amount: 2000000,
        date: DateTime(2025, 11, 1),
        description: 'Gaji satpam untuk bulan November',
      ),
      ExpenseItem(
        id: '5',
        title: 'Pembangunan Taman RT',
        category: ExpenseCategory.pembangunan,
        amount: 8000000,
        date: DateTime(2025, 10, 15),
        description: 'Pembangunan taman untuk fasilitas warga',
      ),
    ];
  }
}
