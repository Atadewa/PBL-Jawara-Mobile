import 'dart:io';
import 'dart:typed_data';
import '../../../../core/auth/backend_api_client.dart';
import '../models/broadcast.dart';
import 'package:dio/dio.dart';

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

  /// Create new broadcast
  /// POST /broadcasts
  /// Requires manage permission (admin, ketua_rw, ketua_rt, sekretaris)
  Future<Broadcast> createBroadcast(Map<String, dynamic> data) async {
    try {
      print('[BroadcastService] Creating broadcast with data: $data');
      final response = await _apiClient.post('/broadcasts', data: data);

      print(
        '[BroadcastService] Create response status: ${response.statusCode}',
      );
      print(
        '[BroadcastService] Create response type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data;

        // Handle different response formats
        Map<String, dynamic>? broadcastData;

        if (responseData is Map) {
          print(
            '[BroadcastService] Response is Map with keys: ${responseData.keys}',
          );

          if (responseData['data'] != null) {
            broadcastData = Map<String, dynamic>.from(responseData['data']);
          } else if (responseData['id'] != null) {
            // Direct broadcast object without wrapper
            broadcastData = Map<String, dynamic>.from(responseData);
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          print('[BroadcastService] Response is List, taking first element');
          broadcastData = Map<String, dynamic>.from(responseData[0]);
        }

        if (broadcastData != null) {
          print(
            '[BroadcastService] Parsing broadcast data: ${broadcastData.keys}',
          );
          return Broadcast.fromJson(broadcastData);
        }

        throw Exception('Invalid response format: no broadcast data found');
      } else {
        throw Exception('Failed to create broadcast: ${response.statusCode}');
      }
    } catch (e) {
      print('[BroadcastService] Error creating broadcast: $e');
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to create broadcast';
        throw Exception(message);
      }
      throw Exception('Error creating broadcast: $e');
    }
  }

  /// Update broadcast
  /// PATCH /broadcasts/:id
  /// Requires manage permission and scope check
  Future<Broadcast> updateBroadcast(int id, Map<String, dynamic> data) async {
    try {
      print('[BroadcastService] Updating broadcast $id with data: $data');
      final response = await _apiClient.patch('/broadcasts/$id', data: data);

      print(
        '[BroadcastService] Update response status: ${response.statusCode}',
      );
      print(
        '[BroadcastService] Update response type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        // Handle different response formats
        Map<String, dynamic>? broadcastData;

        if (responseData is Map) {
          if (responseData['data'] != null) {
            broadcastData = Map<String, dynamic>.from(responseData['data']);
          } else if (responseData['id'] != null) {
            broadcastData = Map<String, dynamic>.from(responseData);
          }
        } else if (responseData is List && responseData.isNotEmpty) {
          broadcastData = Map<String, dynamic>.from(responseData[0]);
        }

        if (broadcastData != null) {
          return Broadcast.fromJson(broadcastData);
        }

        throw Exception('Invalid response format: no broadcast data found');
      } else {
        throw Exception('Failed to update broadcast: ${response.statusCode}');
      }
    } catch (e) {
      print('[BroadcastService] Error updating broadcast: $e');
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to update broadcast';
        throw Exception(message);
      }
      throw Exception('Error updating broadcast: $e');
    }
  }

  /// Delete broadcast
  /// DELETE /broadcasts/:id (if implemented in backend)
  /// Requires manage permission and scope check
  Future<void> deleteBroadcast(int id) async {
    try {
      final response = await _apiClient.delete('/broadcasts/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete broadcast: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to delete broadcast';
        throw Exception(message);
      }
      throw Exception('Error deleting broadcast: $e');
    }
  }

  /// Publish broadcast (change status to published)
  /// PATCH /broadcasts/:id/publish
  /// Requires manage permission and scope check
  Future<Broadcast> publishBroadcast(int id) async {
    try {
      final response = await _apiClient.patch('/broadcasts/$id/publish');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return Broadcast.fromJson(
            responseData['data'] as Map<String, dynamic>,
          );
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to publish broadcast: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final message =
            e.response?.data?['message'] ?? 'Failed to publish broadcast';
        throw Exception(message);
      }
      throw Exception('Error publishing broadcast: $e');
    }
  }

  /// Upload image for broadcast
  /// POST /broadcasts/:id/image
  /// Requires manage permission and scope check
  Future<Broadcast> uploadImage(int id, File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/broadcasts/$id/image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return Broadcast.fromJson(
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

  /// Upload image for broadcast from bytes (for web platform)
  /// POST /broadcasts/:id/image
  /// Requires manage permission and scope check
  Future<Broadcast> uploadImageBytes(
    int id,
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: filename),
      });

      final response = await _apiClient.post(
        '/broadcasts/$id/image',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return Broadcast.fromJson(
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
