import 'dart:io';
import 'dart:typed_data';
import '../../../../core/auth/backend_api_client.dart';
import '../models/event_model.dart';
import 'package:dio/dio.dart';

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

  /// Create new event
  /// POST /events
  /// Requires manage permission (admin, ketua_rw, ketua_rt, sekretaris)
  Future<EventModel> createEvent(Map<String, dynamic> data) async {
    try {
      print('[EventService] Creating event with data: $data');
      final response = await _apiClient.post('/events', data: data);

      print('[EventService] Create response status: ${response.statusCode}');
      print(
        '[EventService] Create response type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data;

        // Handle different response formats
        Map<String, dynamic>? eventData;

        if (responseData is Map) {
          print(
            '[EventService] Response is Map with keys: ${responseData.keys}',
          );

          if (responseData['data'] != null) {
            eventData = Map<String, dynamic>.from(responseData['data']);
          } else if (responseData['id'] != null) {
            // Direct event object without wrapper
            eventData = Map<String, dynamic>.from(responseData);
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          print('[EventService] Response is List, taking first element');
          eventData = Map<String, dynamic>.from(responseData[0]);
        }

        if (eventData != null) {
          print('[EventService] Parsing event data: ${eventData.keys}');
          return EventModel.fromJson(eventData);
        }

        throw Exception('Invalid response format: no event data found');
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } catch (e) {
      print('[EventService] Error creating event: $e');
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to create event';
        throw Exception(message);
      }
      throw Exception('Error creating event: $e');
    }
  }

  /// Update event
  /// PATCH /events/:id
  /// Requires manage permission and scope check
  Future<EventModel> updateEvent(int id, Map<String, dynamic> data) async {
    try {
      print('[EventService] Updating event $id with data: $data');
      final response = await _apiClient.patch('/events/$id', data: data);

      print('[EventService] Update response status: ${response.statusCode}');
      print(
        '[EventService] Update response type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        // Handle different response formats
        Map<String, dynamic>? eventData;

        if (responseData is Map) {
          if (responseData['data'] != null) {
            eventData = Map<String, dynamic>.from(responseData['data']);
          } else if (responseData['id'] != null) {
            eventData = Map<String, dynamic>.from(responseData);
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          eventData = Map<String, dynamic>.from(responseData[0]);
        }

        if (eventData != null) {
          return EventModel.fromJson(eventData);
        }

        throw Exception('Invalid response format: no event data found');
      } else {
        throw Exception('Failed to update event: ${response.statusCode}');
      }
    } catch (e) {
      print('[EventService] Error updating event: $e');
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to update event';
        throw Exception(message);
      }
      throw Exception('Error updating event: $e');
    }
  }

  /// Delete event
  /// DELETE /events/:id (if implemented in backend)
  /// Requires manage permission and scope check
  Future<void> deleteEvent(int id) async {
    try {
      final response = await _apiClient.delete('/events/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to delete event';
        throw Exception(message);
      }
      throw Exception('Error deleting event: $e');
    }
  }

  /// Update event status
  /// PATCH /events/:id/status
  /// Requires manage permission and scope check
  Future<EventModel> updateEventStatus(int id, String status) async {
    try {
      final response = await _apiClient.patch(
        '/events/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return EventModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception(
          'Failed to update event status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to update event status';
        throw Exception(message);
      }
      throw Exception('Error updating event status: $e');
    }
  }

  /// Upload image for event
  /// POST /events/:id/image
  /// Requires manage permission and scope check
  Future<EventModel> uploadImage(int id, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/events/$id/image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return EventModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to upload image';
        throw Exception(message);
      }
      throw Exception('Error uploading image: $e');
    }
  }

  /// Upload image for event from bytes (for web platform)
  /// POST /events/:id/image
  /// Requires manage permission and scope check
  Future<EventModel> uploadImageBytes(
    int id,
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: filename),
      });

      final response = await _apiClient.post(
        '/events/$id/image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return EventModel.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to upload image';
        throw Exception(message);
      }
      throw Exception('Error uploading image: $e');
    }
  }
}
