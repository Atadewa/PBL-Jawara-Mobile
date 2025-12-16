import '../models/finance_model.dart';
import '../models/common_model.dart';

/// Service untuk menangani data finance dashboard
///
/// LANGKAH MIGRASI KE API REAL:
/// 1. Tambahkan http package ke pubspec.yaml: `http: ^1.1.0`
/// 2. Import: `import 'package:http/http.dart' as http;`
/// 3. Buat ApiConstants class untuk base URL dan endpoints
/// 4. Implementasikan getFinanceDashboard() dengan HTTP GET call
/// 5. Handle error responses dan timeout
/// 6. Gunakan try-catch untuk error handling
/// 7. Tambahkan authentication header jika diperlukan

class FinanceService {
  final String? authToken;
  final bool useMockData; // Toggle untuk mock data vs API real

  FinanceService({
    this.authToken,
    this.useMockData = true, // Default pakai mock data
  });

  /// Fetch finance dashboard data
  Future<FinanceDashboardData> getFinanceDashboard() async {
    if (useMockData) {
      // Simulasi delay network
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockData();
    }

    // TODO: Implementasi real API call di sini:
    // try {
    //   final response = await http.get(
    //     Uri.parse('${ApiConstants.baseUrl}${ApiConstants.financeDashboardEndpoint}'),
    //     headers: {
    //       'Authorization': 'Bearer $authToken',
    //       'Content-Type': 'application/json',
    //     },
    //   ).timeout(
    //     const Duration(seconds: 30),
    //     onTimeout: () => throw TimeoutException('API request timeout'),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     final json = jsonDecode(response.body);
    //     return FinanceDashboardData.fromJson(json['data']);
    //   } else if (response.statusCode == 401) {
    //     throw UnauthorizedException('Token expired or invalid');
    //   } else {
    //     throw ServerException('Failed to load finance data: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   rethrow;
    // }

    return _getMockData();
  }

  /// Refresh finance dashboard data
  Future<FinanceDashboardData> refreshFinanceDashboard() async {
    return getFinanceDashboard();
  }

  /// Get mock finance data
  FinanceDashboardData _getMockData() {
    return FinanceDashboardData(
      summary: FinanceSummary(
        totalIncome: '86000000', // 86 Jt
        totalExpense: '54000000', // 54 Jt
        balance: '32000000', // 32 Jt
      ),
      // Data pemasukan per bulan (6 bulan terakhir)
      incomeMonthly: [
        MonthlySeries(month: 'Jan', value: 10000000),
        MonthlySeries(month: 'Feb', value: 12000000),
        MonthlySeries(month: 'Mar', value: 14000000),
        MonthlySeries(month: 'Apr', value: 15000000),
        MonthlySeries(month: 'Mei', value: 16000000),
        MonthlySeries(month: 'Jun', value: 19000000),
      ],
      // Data pengeluaran per bulan
      expenseMonthly: [
        MonthlySeries(month: 'Jan', value: 6000000),
        MonthlySeries(month: 'Feb', value: 7000000),
        MonthlySeries(month: 'Mar', value: 8000000),
        MonthlySeries(month: 'Apr', value: 8500000),
        MonthlySeries(month: 'Mei', value: 9000000),
        MonthlySeries(month: 'Jun', value: 15500000),
      ],
      // Kategori pemasukan
      incomeCategories: [
        CategoryBreakdown(
          category: 'Iuran Kebersihan',
          amount: 24000000,
          color: '0xFF10B981',
        ),
        CategoryBreakdown(
          category: 'Iuran Satpam',
          amount: 36000000,
          color: '0xFF34D399',
        ),
        CategoryBreakdown(
          category: 'Iuran Sampah',
          amount: 18000000,
          color: '0xFF10B981',
        ),
        CategoryBreakdown(
          category: 'Lain-lain',
          amount: 8000000,
          color: '0xFF059669',
        ),
      ],
      // Kategori pengeluaran
      expenseCategories: [
        CategoryBreakdown(
          category: 'Gaji Satpam',
          amount: 24000000,
          color: '0xFF10B981',
        ),
        CategoryBreakdown(
          category: 'Kebersihan',
          amount: 12000000,
          color: '0xFF34D399',
        ),
        CategoryBreakdown(
          category: 'Pemeliharaan',
          amount: 10000000,
          color: '0xFF10B981',
        ),
        CategoryBreakdown(
          category: 'Operasional',
          amount: 8000000,
          color: '0xFF059669',
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}
