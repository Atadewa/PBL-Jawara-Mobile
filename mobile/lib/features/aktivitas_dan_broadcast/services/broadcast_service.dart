import '../../../../core/auth/backend_api_client.dart';
import '../models/broadcast.dart';

/// Service for fetching broadcast/announcement data from backend
class BroadcastService {
  final BackendApiClient _apiClient = BackendApiClient();

  /// Fetch list of broadcasts
  /// Backend automatically filters by user's scope (rw/rt)
  /// GET /broadcasts
  Future<List<Broadcast>> getBroadcastList() async {
    try {
      final response = await _apiClient.get('/broadcasts');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Handle both array response and object with data property
        List<dynamic> broadcastList;
        if (data is List) {
          broadcastList = data;
        } else if (data is Map && data['data'] is List) {
          broadcastList = data['data'] as List;
        } else {
          broadcastList = [];
        }

        return broadcastList
            .map((json) => Broadcast.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load broadcasts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching broadcasts: $e');
    }
  }

  /// Fetch single broadcast by ID
  /// GET /broadcasts/:id
  Future<Broadcast> getBroadcastById(int id) async {
    try {
      final response = await _apiClient.get('/broadcasts/$id');

      if (response.statusCode == 200 && response.data != null) {
        // Handle both direct object and {data: object} response
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return Broadcast.fromJson(data['data'] as Map<String, dynamic>);
          }
          return Broadcast.fromJson(data);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load broadcast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching broadcast: $e');
    }
  }
}
