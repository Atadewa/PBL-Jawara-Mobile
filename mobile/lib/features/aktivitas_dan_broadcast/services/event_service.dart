import '../../../../core/auth/backend_api_client.dart';
import '../models/event_model.dart';

/// Service for fetching event/kegiatan data from backend
class EventService {
  final BackendApiClient _apiClient = BackendApiClient();

  /// Fetch list of events
  /// Backend automatically filters by user's scope (rw/rt)
  /// GET /events
  Future<List<EventModel>> getEventList() async {
    try {
      final response = await _apiClient.get('/events');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Handle both array response and object with data property
        List<dynamic> eventList;
        if (data is List) {
          eventList = data;
        } else if (data is Map && data['data'] is List) {
          eventList = data['data'] as List;
        } else {
          eventList = [];
        }

        return eventList
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  /// Fetch single event by ID
  /// GET /events/:id
  Future<EventModel> getEventById(int id) async {
    try {
      print('[EventService] Fetching event id: $id');
      final response = await _apiClient.get('/events/$id');

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;

        // Handle wrapper {data: {...}} or direct object
        final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;

        // Debug: print response keys
        print('[EventService] Event detail keys: ${data.keys}');
        print(
          '[EventService] Event detail description: ${data['description']}',
        );

        return EventModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        throw Exception('Failed to load event: ${response.statusCode}');
      }
    } catch (e) {
      print('[EventService] Error fetching event: $e');
      throw Exception('Error fetching event: $e');
    }
  }
}
