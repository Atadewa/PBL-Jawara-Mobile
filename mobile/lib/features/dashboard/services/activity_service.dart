import '../models/activity_model.dart';
import '../models/common_model.dart';

/// Service untuk menangani data activity dashboard
///
/// LANGKAH MIGRASI KE API REAL:
/// 1. Tambahkan http package ke pubspec.yaml: `http: ^1.1.0`
/// 2. Import: `import 'package:http/http.dart' as http;`
/// 3. Buat ApiConstants class untuk base URL dan endpoints
/// 4. Implementasikan getActivityDashboard() dengan HTTP GET call
/// 5. Handle error responses dan timeout
/// 6. Gunakan try-catch untuk error handling
/// 7. Tambahkan authentication header jika diperlukan

class ActivityService {
  final String? authToken;
  final bool useMockData; // Toggle untuk mock data vs API real

  ActivityService({
    this.authToken,
    this.useMockData = true, // Default pakai mock data
  });

  /// Fetch activity dashboard data
  Future<ActivityDashboardData> getActivityDashboard() async {
    if (useMockData) {
      // Simulasi delay network
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockData();
    }

    // TODO: Implementasi real API call di sini:
    // try {
    //   final response = await http.get(
    //     Uri.parse('${ApiConstants.baseUrl}${ApiConstants.activityDashboardEndpoint}'),
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
    //     return ActivityDashboardData.fromJson(json['data']);
    //   } else if (response.statusCode == 401) {
    //     throw UnauthorizedException('Token expired or invalid');
    //   } else {
    //     throw ServerException('Failed to load activity data: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   rethrow;
    // }

    return _getMockData();
  }

  /// Refresh activity dashboard data
  Future<ActivityDashboardData> refreshActivityDashboard() async {
    return getActivityDashboard();
  }

  /// Get mock activity data
  ActivityDashboardData _getMockData() {
    return ActivityDashboardData(
      summary: ActivitySummary(
        totalActivities: '70', // Total kegiatan tahun ini
        completed: '42', // Selesai
        today: '3', // Hari ini
        upcoming: '25', // Mendatang
      ),
      // Data kegiatan per bulan (6 bulan)
      monthlyActivities: [
        MonthlySeries(month: 'Jan', value: 8),
        MonthlySeries(month: 'Feb', value: 10),
        MonthlySeries(month: 'Mar', value: 12),
        MonthlySeries(month: 'Apr', value: 11),
        MonthlySeries(month: 'Mei', value: 14),
        MonthlySeries(month: 'Jun', value: 15),
      ],
      // Kategori kegiatan breakdown
      categories: [
        ActivityCategory(
          category: 'Sosial',
          count: 25,
          color: '0xFF10B981',
          percentage: 35,
        ),
        ActivityCategory(
          category: 'Keamanan',
          count: 18,
          color: '0xFF34D399',
          percentage: 25,
        ),
        ActivityCategory(
          category: 'Kebersihan',
          count: 14,
          color: '0xFF10B981',
          percentage: 20,
        ),
        ActivityCategory(
          category: 'Lain-lain',
          count: 13,
          color: '0xFF059669',
          percentage: 20,
        ),
      ],
      // Top 4 penanggung jawab kegiatan
      topResponsiblePersons: [
        PersonRanking(
          rank: 1,
          name: 'Budi Santoso',
          activityCount: 28,
          color: '0xFFFACC15', // Yellow
        ),
        PersonRanking(
          rank: 2,
          name: 'Siti Rahayu',
          activityCount: 24,
          color: '0xFF94A3B8', // Gray
        ),
        PersonRanking(
          rank: 3,
          name: 'Ahmad Hidayat',
          activityCount: 20,
          color: '0xFFF97316', // Orange
        ),
        PersonRanking(
          rank: 4,
          name: 'Dewi Kusuma',
          activityCount: 18,
          color: '0xFF10B981', // Teal
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
}
