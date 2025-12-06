import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/activity_log_item.dart';
import '../models/user_role.dart';

class ActivityLogService {
  static const String _endpoint = '/activity-logs';

  // Get all activity logs with optional filters
  Future<List<ActivityLogItem>> getActivityLogs({
    List<UserRole>? roles,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (ApiConfig.useDummyData) {
      return _getDummyActivityLogs(
          roles: roles, startDate: startDate, endDate: endDate);
    }

    try {
      final queryParams = <String, String>{};
      if (roles != null && roles.isNotEmpty) {
        queryParams['roles'] = roles.map((r) => r.displayName).join(',');
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}$_endpoint')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ActivityLogItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activity logs');
      }
    } catch (e) {
      throw Exception('Error fetching activity logs: $e');
    }
  }

  // Dummy data for testing
  List<ActivityLogItem> _getDummyActivityLogs({
    List<UserRole>? roles,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final allLogs = [
      ActivityLogItem(
        id: '1',
        role: UserRole.admin,
        description: 'Admin menyetujui warga baru',
        timestamp: DateTime(2025, 11, 25, 14, 30),
      ),
      ActivityLogItem(
        id: '2',
        role: UserRole.ketuaRT,
        description: 'Ketua RT mengubah data keluarga',
        timestamp: DateTime(2025, 11, 25, 13, 15),
      ),
      ActivityLogItem(
        id: '3',
        role: UserRole.warga,
        description: 'Warga melakukan pembayaran iuran',
        timestamp: DateTime(2025, 11, 25, 11, 45),
      ),
      ActivityLogItem(
        id: '4',
        role: UserRole.bendahara,
        description: 'Bendahara menambahkan pemasukan lain-lain',
        timestamp: DateTime(2025, 11, 24, 16, 20),
      ),
      ActivityLogItem(
        id: '5',
        role: UserRole.sekretaris,
        description: 'Sekretaris menambahkan kegiatan baru',
        timestamp: DateTime(2025, 11, 24, 10, 0),
      ),
      ActivityLogItem(
        id: '6',
        role: UserRole.admin,
        description: 'Admin menolak permohonan warga baru',
        timestamp: DateTime(2025, 11, 23, 15, 30),
      ),
      ActivityLogItem(
        id: '7',
        role: UserRole.ketuaRW,
        description: 'Ketua RW menyetujui anggaran kegiatan',
        timestamp: DateTime(2025, 11, 23, 9, 0),
      ),
      ActivityLogItem(
        id: '8',
        role: UserRole.warga,
        description: 'Warga mengajukan permohonan verifikasi',
        timestamp: DateTime(2025, 11, 22, 14, 15),
      ),
    ];

    // Apply filters
    var filteredLogs = allLogs;

    if (roles != null && roles.isNotEmpty) {
      filteredLogs = filteredLogs.where((log) => roles.contains(log.role)).toList();
    }

    if (startDate != null) {
      filteredLogs = filteredLogs
          .where((log) => log.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))))
          .toList();
    }

    if (endDate != null) {
      filteredLogs = filteredLogs
          .where((log) => log.timestamp.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    // Sort by timestamp descending (newest first)
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filteredLogs;
  }
}
