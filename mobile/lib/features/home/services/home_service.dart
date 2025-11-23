import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_stats.dart';
import '../models/user_info.dart';
import '../../../core/config/api_config.dart';

/// Service untuk mengambil data home dari API
class HomeService {
  // Base URL dan konfigurasi diambil dari ApiConfig
  // Untuk mengubah base URL atau useDummyData, edit file: lib/core/config/api_config.dart
  static const String _baseUrl = ApiConfig.baseUrl;
  static const bool _useDummyData = ApiConfig.useDummyData;

  /// Get data statistik home
  ///
  /// TODO: Saat production:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Update ApiConfig.baseUrl dengan URL production
  /// 3. Ganti endpoint dengan API real
  /// Contoh: GET /api/home/stats
  Future<HomeStats> getHomeStats() async {
    // Menggunakan dummy data untuk development
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 500));

      return HomeStats(
        totalWarga: 245,
        totalKeluarga: 68,
        pemasukan: 'Rp 15,2 Jt',
        pengeluaran: 'Rp 2,7 Jt',
      );
    }

    // TODO: Implementasi real API call
    // Contoh implementasi:
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/home/stats'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HomeStats.fromJson(data);
      } else {
        throw Exception('Failed to load home stats');
      }
    } catch (e) {
      throw Exception('Error fetching home stats: $e');
    }
  }

  /// Get informasi user yang sedang login
  ///
  /// TODO: Saat production:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Update ApiConfig.baseUrl dengan URL production
  /// 3. Ganti endpoint dengan API real
  /// Contoh: GET /api/user/profile
  Future<UserInfo> getUserInfo() async {
    // Menggunakan dummy data untuk development
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 500));

      return UserInfo(
        name: 'Pengurus RT/RW',
        role: 'Pengurus RT/RW',
        rtRw: 'RT 01 / RW 05',
      );
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer \$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserInfo.fromJson(data);
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      throw Exception('Error fetching user info: \$e');
    }
  }

  /// Load semua data yang diperlukan untuk home page
  Future<Map<String, dynamic>> loadHomeData() async {
    try {
      // Parallel loading untuk performa lebih baik
      final results = await Future.wait([getUserInfo(), getHomeStats()]);

      return {
        'userInfo': results[0] as UserInfo,
        'stats': results[1] as HomeStats,
      };
    } catch (e) {
      throw Exception('Error loading home data: $e');
    }
  }
}
