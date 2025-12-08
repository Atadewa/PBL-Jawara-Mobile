import '../models/population_model.dart';

/// Service untuk menangani data population dashboard
///
/// LANGKAH MIGRASI KE API REAL:
/// 1. Tambahkan http package ke pubspec.yaml: `http: ^1.1.0`
/// 2. Import: `import 'package:http/http.dart' as http;`
/// 3. Buat ApiConstants class untuk base URL dan endpoints:
///    - const String BASE_URL = 'https://api.example.com';
///    - const String POPULATION_ENDPOINT = '/api/v1/population/dashboard';
/// 4. Implementasikan getPopulationDashboard() dengan HTTP GET call:
///    ```
///    final response = await http.get(
///      Uri.parse('$BASE_URL$POPULATION_ENDPOINT'),
///      headers: {'Authorization': 'Bearer $authToken'},
///    );
///    if (response.statusCode == 200) {
///      return PopulationDashboardData.fromJson(json.decode(response.body));
///    } else {
///      throw Exception('Failed to load population data');
///    }
///    ```
/// 5. Handle error responses dan timeout:
///    - Catch TimeoutException untuk timeout handling
///    - Catch FormatException untuk JSON parsing errors
///    - Catch SocketException untuk network errors
/// 6. Gunakan try-catch untuk error handling di repository layer
/// 7. Tambahkan authentication header jika diperlukan (Bearer token)
/// 8. Implementasikan caching untuk mengurangi API calls
/// 9. Tambahkan pagination jika data sangat besar

class PopulationService {
  final String? authToken;
  final bool useMockData; // Toggle untuk mock data vs API real

  PopulationService({
    this.authToken,
    this.useMockData = true, // Default pakai mock data
  });

  /// Fetch population dashboard data
  Future<PopulationDashboardData> getPopulationDashboard() async {
    if (useMockData) {
      // Simulasi delay network
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockData();
    }

    // TODO: Implementasi real API call di sini:
    // 1. Buat HTTP GET request ke endpoint population dashboard
    // 2. Parse response JSON ke PopulationDashboardData
    // 3. Handle error responses
    // 4. Return data atau throw exception

    throw UnimplementedError(
      'Real API implementation needed. '
      'See migration steps in class documentation.',
    );
  }

  /// Get mock data untuk development
  PopulationDashboardData _getMockData() {
    return PopulationDashboardData(
      summary: PopulationSummary(totalFamilies: '342', totalResidents: '1,248'),
      residentStatus: PopulationAnalysis(
        categoryTitle: 'Status Penduduk',
        data: [
          PopulationCategory(
            name: 'Aktif',
            count: 1180,
            color: '0xFF10B981',
            percentage: 94.6,
          ),
          PopulationCategory(
            name: 'Nonaktif',
            count: 68,
            color: '0xFF94A3B8',
            percentage: 5.4,
          ),
        ],
      ),
      gender: PopulationAnalysis(
        categoryTitle: 'Jenis Kelamin',
        data: [
          PopulationCategory(
            name: 'Laki-laki',
            count: 620,
            color: '0xFF6EE7B7',
            percentage: 49.7,
          ),
          PopulationCategory(
            name: 'Perempuan',
            count: 628,
            color: '0xFFF472B6',
            percentage: 50.3,
          ),
        ],
      ),
      occupation: PopulationAnalysis(
        categoryTitle: 'Pekerjaan',
        data: [
          PopulationCategory(
            name: 'Pegawai Swasta',
            count: 374,
            color: '0xFF6EE7B7',
            percentage: 30.0,
          ),
          PopulationCategory(
            name: 'PNS',
            count: 225,
            color: '0xFF34D399',
            percentage: 18.0,
          ),
          PopulationCategory(
            name: 'Wiraswasta',
            count: 175,
            color: '0xFF10B981',
            percentage: 14.0,
          ),
          PopulationCategory(
            name: 'Pelajar',
            count: 274,
            color: '0xFF059669',
            percentage: 22.0,
          ),
          PopulationCategory(
            name: 'Lainnya',
            count: 187,
            color: '0xFF047857',
            percentage: 15.0,
          ),
        ],
      ),
      religion: PopulationAnalysis(
        categoryTitle: 'Agama',
        data: [
          PopulationCategory(
            name: 'Islam',
            count: 986,
            color: '0xFF6EE7B7',
            percentage: 79.0,
          ),
          PopulationCategory(
            name: 'Kristen',
            count: 150,
            color: '0xFF34D399',
            percentage: 12.0,
          ),
          PopulationCategory(
            name: 'Katolik',
            count: 75,
            color: '0xFF10B981',
            percentage: 6.0,
          ),
          PopulationCategory(
            name: 'Hindu',
            count: 25,
            color: '0xFF059669',
            percentage: 2.0,
          ),
          PopulationCategory(
            name: 'Buddha',
            count: 12,
            color: '0xFF047857',
            percentage: 1.0,
          ),
        ],
      ),
      familyRole: PopulationAnalysis(
        categoryTitle: 'Peran dalam Keluarga',
        data: [
          PopulationCategory(
            name: 'Kepala Keluarga',
            count: 337,
            color: '0xFF6EE7B7',
            percentage: 27.0,
          ),
          PopulationCategory(
            name: 'Istri',
            count: 324,
            color: '0xFF34D399',
            percentage: 26.0,
          ),
          PopulationCategory(
            name: 'Anak',
            count: 524,
            color: '0xFF10B981',
            percentage: 42.0,
          ),
          PopulationCategory(
            name: 'Lainnya',
            count: 63,
            color: '0xFF059669',
            percentage: 5.0,
          ),
        ],
      ),
      education: PopulationAnalysis(
        categoryTitle: 'Pendidikan',
        data: [
          PopulationCategory(
            name: 'SD',
            count: 175,
            color: '0xFF6EE7B7',
            percentage: 14.0,
          ),
          PopulationCategory(
            name: 'SMP',
            count: 225,
            color: '0xFF34D399',
            percentage: 18.0,
          ),
          PopulationCategory(
            name: 'SMA',
            count: 374,
            color: '0xFF10B981',
            percentage: 30.0,
          ),
          PopulationCategory(
            name: 'D3',
            count: 125,
            color: '0xFF059669',
            percentage: 10.0,
          ),
          PopulationCategory(
            name: 'S1',
            count: 275,
            color: '0xFF047857',
            percentage: 22.0,
          ),
          PopulationCategory(
            name: 'S2/S3',
            count: 62,
            color: '0xFF065F46',
            percentage: 5.0,
          ),
        ],
      ),
      lastUpdated: DateTime.now(),
    );
  }
}
