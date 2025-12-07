import '../models/dashboard_model.dart';

/// Service untuk menangani data dashboard
///
/// LANGKAH MIGRASI KE API REAL:
/// 1. Tambahkan http package ke pubspec.yaml: `http: ^1.1.0`
/// 2. Import: `import 'package:http/http.dart' as http;`
/// 3. Buat ApiConstants class untuk base URL dan endpoints
/// 4. Implementasikan getDashboardData() dengan HTTP GET call
/// 5. Handle error responses dan timeout
/// 6. Gunakan try-catch untuk error handling
/// 7. Tambahkan authentication header jika diperlukan

class DashboardService {
  final String? authToken;
  final bool useMockData; // Toggle untuk mock data vs API real

  DashboardService({
    this.authToken,
    this.useMockData = true, // Default pakai mock data
  });

  /// Fetch dashboard data dari API atau dummy data
  Future<DashboardData> getDashboardData() async {
    if (useMockData) {
      // Simulasi delay network untuk dummy data
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockDashboardData();
    }

    // TODO: Implementasi real API call di sini:
    // try {
    //   final response = await http.get(
    //     Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardEndpoint}'),
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
    //     return DashboardData.fromJson(json['data']);
    //   } else if (response.statusCode == 401) {
    //     throw UnauthorizedException('Token expired or invalid');
    //   } else {
    //     throw ServerException('Failed to load dashboard: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   rethrow;
    // }

    return _getMockDashboardData();
  }

  /// Refresh dashboard data
  Future<DashboardData> refreshDashboardData() async {
    return getDashboardData();
  }

  /// Get mock dashboard data untuk development
  DashboardData _getMockDashboardData() {
    return DashboardData(
      title: 'Masuk ke Jawara Pintar',
      subtitle: 'Kelola lingkungan RT/RW Anda secara mudah dan modern',
      userLocation: 'Anda sedang berada di lingkungan RT 01 / RW 05',
      widgets: _getMockWidgets(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Get mock widgets data
  List<DashboardWidget> _getMockWidgets() {
    return [
      // Top stat cards
      DashboardWidget(
        id: 'stat_1',
        type: 'stat_card',
        title: 'Total Warga',
        value: 1248,
        icon: 'people',
        color: '0xFF6EE7B7',
      ),
      DashboardWidget(
        id: 'stat_2',
        type: 'stat_card',
        title: 'Total Keluarga',
        value: 342,
        icon: 'home',
        color: '0xFF6EE7B7',
      ),
      DashboardWidget(
        id: 'stat_3',
        type: 'stat_card',
        title: 'Pemasukan',
        value: '18 Jt',
        icon: 'trending_up',
        color: '0xFF10B981',
      ),
      DashboardWidget(
        id: 'stat_4',
        type: 'stat_card',
        title: 'Pengeluaran',
        value: '11 Jt',
        icon: 'trending_down',
        color: '0xFFEF4444',
      ),
    ];
  }
}
