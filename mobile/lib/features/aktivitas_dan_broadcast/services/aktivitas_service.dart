import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kegiatan.dart';
import '../models/kegiatan_detail.dart';
import '../models/broadcast.dart';
import '../../../core/config/api_config.dart';

/// Service untuk mengambil data aktivitas dan broadcast dari API
///
/// Struktur file:
/// - lib/core/config/api_config.dart: Konfigurasi base URL dan mode dummy data
/// - lib/features/aktivitas_dan_broadcast/models/: Data models
/// - lib/features/aktivitas_dan_broadcast/services/: Service/API calls
/// - lib/features/aktivitas_dan_broadcast/pages/: UI Pages
/// - lib/features/aktivitas_dan_broadcast/widgets/: Reusable UI components
class AktivitasService {
  // Base URL dan konfigurasi diambil dari ApiConfig
  // Untuk mengubah base URL atau useDummyData, edit file: lib/core/config/api_config.dart
  static const String _baseUrl = ApiConfig.baseUrl;
  static const bool _useDummyData = ApiConfig.useDummyData;

  /// Get list kegiatan dengan search dan filter
  ///
  /// TODO: Saat production:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Update ApiConfig.baseUrl dengan URL production
  /// 3. Implementasi API call berikut:
  ///    - GET /api/aktivitas/kegiatan (list kegiatan dengan pagination)
  ///    - Query params: page, limit, search, category
  Future<List<Kegiatan>> getKegiatanList({
    String? search,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    // Menggunakan dummy data untuk development
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 600));

      // Dummy data kegiatan
      final dummyData = [
        Kegiatan(
          id: 'kegiatan_001',
          title: 'Gotong Royong Bulanan',
          category: 'Kebersihan',
          categoryColor: '#DBEA FE',
          categoryTextColor: '#1347E5',
          date: '28 November 2025',
          organizer: 'Bapak Ahmad',
          categoryIcon: 'cleaning',
        ),
        Kegiatan(
          id: 'kegiatan_002',
          title: 'Perayaan HUT RI ke-80',
          category: 'Perayaan',
          categoryColor: '#F3E8FF',
          categoryTextColor: '#8200DA',
          date: '17 Agustus 2025',
          organizer: 'Ibu Siti',
          categoryIcon: 'celebration',
        ),
        Kegiatan(
          id: 'kegiatan_003',
          title: 'Rapat RT Rutin',
          category: 'Rapat',
          categoryColor: '#FFEDD4',
          categoryTextColor: '#C93400',
          date: '5 Desember 2025',
          organizer: 'Bapak Joko',
          categoryIcon: 'meeting',
        ),
        Kegiatan(
          id: 'kegiatan_004',
          title: 'Posyandu Balita',
          category: 'Kesehatan',
          categoryColor: '#DCFCE7',
          categoryTextColor: '#008235',
          date: '30 November 2025',
          organizer: 'Ibu Rina',
          categoryIcon: 'health',
        ),
        Kegiatan(
          id: 'kegiatan_005',
          title: 'Pengajian Rutin',
          category: 'Keagamaan',
          categoryColor: '#E0E7FF',
          categoryTextColor: '#432DD7',
          date: '1 Desember 2025',
          organizer: 'Bapak Hasan',
          categoryIcon: 'religion',
        ),
      ];

      // Apply search filter
      var filtered = dummyData;
      if (search != null && search.isNotEmpty) {
        filtered = filtered
            .where(
              (k) =>
                  k.title.toLowerCase().contains(search.toLowerCase()) ||
                  k.category.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
      }

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((k) => k.category == category).toList();
      }

      return filtered;
    }

    // TODO: Implementasi real API call
    // Contoh implementasi:
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      };

      final uri = Uri.parse(
        '$_baseUrl/api/aktivitas/kegiatan',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Sesuaikan dengan struktur response API
        final List<dynamic> kegiatanList = data['data'] ?? [];
        return kegiatanList
            .map((k) => Kegiatan.fromJson(k as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching kegiatan: $e');
    }
  }

  /// Get detail kegiatan berdasarkan ID
  ///
  /// TODO: Saat production:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Implementasi API call: GET /api/aktivitas/kegiatan/:id
  Future<Kegiatan> getKegiatanDetail(String id) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));

      // Return salah satu dummy data berdasarkan ID
      final list = await getKegiatanList();
      return list.firstWhere((k) => k.id == id);
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/$id'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Kegiatan.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to load kegiatan detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching kegiatan detail: $e');
    }
  }

  /// Get list broadcast/pengumuman
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: GET /api/aktivitas/broadcast (dengan pagination)
  /// 2. Query params: page, limit, search
  Future<List<Broadcast>> getBroadcastList({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 600));

      // Dummy data broadcast (untuk pengembangan)
      final dummyData = [
        Broadcast(
          id: 'broadcast_001',
          title: 'Pengumuman Jadwal Perbaikan Jalan',
          description:
              'Perbaikan jalan akan dilaksanakan minggu depan selama 3 hari.',
          createdAt: DateTime(2025, 12, 1, 10, 0),
          createdBy: 'Ketua RT',
          imageUrl: null,
        ),
        Broadcast(
          id: 'broadcast_002',
          title: 'Perubahan Jadwal Rapat RT',
          description:
              'Rapat RT dipindahkan dari hari Minggu ke hari Senin pukul 19:00.',
          createdAt: DateTime(2025, 11, 30, 14, 0),
          createdBy: 'Sekretaris RT',
          imageUrl: null,
        ),
      ];

      // Apply search filter
      var filtered = dummyData;
      if (search != null && search.isNotEmpty) {
        filtered = filtered
            .where(
              (b) =>
                  b.title.toLowerCase().contains(search.toLowerCase()) ||
                  b.description.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
      }

      return filtered;
    }

    // TODO: Implementasi real API call
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse(
        '$_baseUrl/api/aktivitas/broadcast',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Sesuaikan dengan struktur response API
        final List<dynamic> broadcastList = data['data'] ?? [];
        return broadcastList
            .map((b) => Broadcast.fromJson(b as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load broadcast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching broadcast: $e');
    }
  }

  /// Get detail broadcast berdasarkan ID
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: GET /api/aktivitas/broadcast/:id
  Future<Broadcast> getBroadcastDetail(String id) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));

      final list = await getBroadcastList();
      return list.firstWhere((b) => b.id == id);
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/aktivitas/broadcast/$id'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Broadcast.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to load broadcast detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching broadcast detail: $e');
    }
  }

  /// Load semua data yang diperlukan untuk aktivitas & broadcast page
  ///
  /// Menggunakan Future.wait untuk parallel loading agar lebih cepat
  Future<Map<String, dynamic>> loadActivityData() async {
    try {
      // Parallel loading untuk performa lebih baik
      final results = await Future.wait([
        getKegiatanList(),
        getBroadcastList(),
      ]);

      return {
        'kegiatan': results[0] as List<Kegiatan>,
        'broadcast': results[1] as List<Broadcast>,
      };
    } catch (e) {
      throw Exception('Error loading activity data: $e');
    }
  }

  /// Search kegiatan
  Future<List<Kegiatan>> searchKegiatan(String query) async {
    return getKegiatanList(search: query);
  }

  /// Get kategori kegiatan untuk filter
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: GET /api/aktivitas/kegiatan/categories
  Future<List<String>> getKategoriKegiatan() async {
    if (_useDummyData) {
      return [
        'Kebersihan',
        'Perayaan',
        'Rapat',
        'Kesehatan',
        'Keagamaan',
        'Olahraga',
        'Pendidikan',
      ];
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/categories'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Get detail kegiatan dengan semua informasi lengkap untuk detail page
  ///
  /// TODO: Saat production:
  /// 1. Set ApiConfig.useDummyData = false di api_config.dart
  /// 2. Implementasi API call: GET /api/aktivitas/kegiatan/:id/detail
  /// 3. Response harus include: dokumentasi images, deskripsi lengkap, dan metadata
  Future<KegiatanDetail> getKegiatanDetailPage(String id) async {
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data detail kegiatan
      return KegiatanDetail(
        id: id,
        title: 'Gotong Royong Bulanan',
        category: 'Kebersihan',
        categoryColor: '#DBEAFE',
        categoryTextColor: '#1347E5',
        date: DateTime(2025, 11, 28, 9, 0),
        location: 'Balai RT',
        responsiblePerson: 'Bapak Ahmad',
        createdBy: 'Admin RT',
        description:
            'Kegiatan gotong royong rutin bulanan untuk membersihkan lingkungan RT. Warga diharapkan membawa peralatan kebersihan masing-masing seperti sapu, cangkul, dan karung sampah. Kegiatan ini sangat penting untuk menjaga kebersihan dan keindahan lingkungan RT agar tetap nyaman untuk ditinggali.',
        documentationImages: [
          'https://placehold.co/107x107/jpg',
          'https://placehold.co/107x107/jpg',
          'https://placehold.co/107x107/jpg',
        ],
        createdAt: DateTime(2025, 11, 15, 10, 0),
        updatedAt: DateTime(2025, 11, 20, 14, 30),
      );
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/$id/detail'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return KegiatanDetail.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to load kegiatan detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching kegiatan detail: $e');
    }
  }

  /// Delete kegiatan
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: DELETE /api/aktivitas/kegiatan/:id
  /// 2. Memerlukan authorization dan permissions check
  Future<bool> deleteKegiatan(String id) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return true; // Dummy success
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/$id'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting kegiatan: $e');
    }
  }

  /// Update kegiatan dengan data form
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: PUT /api/aktivitas/kegiatan/:id
  /// 2. Body: JSON dari form fields (title, category, date, location, responsible, description)
  /// 3. Memerlukan authorization header
  /// 4. Response berisi updated kegiatan data
  Future<KegiatanDetail> updateKegiatan(
    String id,
    Map<String, dynamic> formData,
  ) async {
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 800));

      // Return updated dummy data dengan form values
      return KegiatanDetail(
        id: id,
        title: formData['title'] ?? 'Gotong Royong Bulanan',
        category: formData['category'] ?? 'Kebersihan',
        categoryColor: formData['categoryColor'] ?? '#DBEAFE',
        categoryTextColor: formData['categoryTextColor'] ?? '#1347E5',
        date: formData['date'] ?? DateTime(2025, 11, 28, 9, 0),
        location: formData['location'] ?? 'Balai RT',
        responsiblePerson: formData['responsiblePerson'] ?? 'Bapak Ahmad',
        createdBy: 'Admin RT',
        description: formData['description'] ?? 'Kegiatan gotong royong...',
        documentationImages: formData['documentationImages'] ?? [],
        createdAt: DateTime(2025, 11, 15, 10, 0),
        updatedAt: DateTime.now(),
      );
    }

    // TODO: Implementasi real API call
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/$id'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return KegiatanDetail.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating kegiatan: $e');
    }
  }

  /// Upload dokumentasi images
  ///
  /// TODO: Saat production:
  /// 1. Implementasi multipart form data upload
  /// 2. API endpoint: POST /api/aktivitas/kegiatan/:id/upload-images
  /// 3. Field: files (multipart/form-data)
  /// 4. Response: list URL dari uploaded images
  Future<List<String>> uploadDocumentationImages(
    String kegiatanId,
    List<String> imagePaths,
  ) async {
    if (_useDummyData) {
      // Simulasi upload dengan delay
      await Future.delayed(Duration(milliseconds: 500 * imagePaths.length));
      // Return dummy URLs
      return List.generate(
        imagePaths.length,
        (index) =>
            'https://api.example.com/images/kegiatan_${kegiatanId}_$index.jpg',
      );
    }

    // TODO: Implementasi real multipart upload
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/aktivitas/kegiatan/$kegiatanId/upload-images'),
      );

      // TODO: Tambahkan authorization header jika diperlukan
      // request.headers.addAll({
      //   'Authorization': 'Bearer $token',
      // });

      // Add files to request
      for (int i = 0; i < imagePaths.length; i++) {
        // TODO: Uncomment saat production untuk read file dari path
        // request.files.add(
        //   await http.MultipartFile.fromPath(
        //     'files',
        //     imagePaths[i],
        //   ),
        // );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return List<String>.from(data['data']['images'] ?? []);
      } else {
        throw Exception('Failed to upload images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  /// Create/tambah kegiatan baru
  ///
  /// TODO: Saat production:
  /// 1. Implementasi API call: POST /api/aktivitas/kegiatan
  /// 2. Body: JSON dari form fields (title, category, date, location, responsible, description)
  /// 3. Handle multipart form data untuk upload images
  /// 4. Memerlukan authorization header
  /// 5. Response berisi created kegiatan data dengan ID
  /// 6. Tambahkan error handling untuk:
  ///    - 400 Bad Request (validation error)
  ///    - 401 Unauthorized (token expired)
  ///    - 409 Conflict (duplicate data)
  ///    - 500 Server error
  Future<KegiatanDetail> createKegiatan(Map<String, dynamic> formData) async {
    if (_useDummyData) {
      // Simulasi loading dari API
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy: Return created kegiatan dengan data dari form
      final images = List<String>.from(formData['documentationImages'] ?? []);

      return KegiatanDetail(
        id: 'kegiatan_${DateTime.now().millisecondsSinceEpoch}',
        title: formData['title'] ?? '',
        category: formData['category'] ?? '',
        categoryColor: formData['categoryColor'] ?? '#DBEAFE',
        categoryTextColor: formData['categoryTextColor'] ?? '#1347E5',
        date: DateTime.now(),
        location: formData['location'] ?? '',
        responsiblePerson: formData['responsiblePerson'] ?? '',
        description: formData['description'] ?? '',
        createdBy: 'Admin RT', // Dummy: dalam production ambil dari auth
        documentationImages: images,
        createdAt: DateTime.now(),
      );
    }

    // TODO: Implementasi real API call untuk production
    try {
      // TODO: Langkah-langkah implementasi:
      // 1. Get auth token dari secure storage
      //    final token = await authService.getAuthToken();
      //
      // 2. Prepare multipart request jika ada images
      //    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/aktivitas/kegiatan'))
      //    request.headers['Authorization'] = 'Bearer $token';
      //
      // 3. Add form fields
      //    request.fields['title'] = formData['title'];
      //    request.fields['category'] = formData['category'];
      //    request.fields['date'] = formData['date'];
      //    request.fields['location'] = formData['location'];
      //    request.fields['responsiblePerson'] = formData['responsiblePerson'];
      //    request.fields['description'] = formData['description'];
      //
      // 4. Add image files
      //    List<String> imagePaths = formData['documentationImages'] ?? [];
      //    for (var imagePath in imagePaths) {
      //      request.files.add(await http.MultipartFile.fromPath('images', imagePath));
      //    }
      //
      // 5. Send request
      //    var response = await request.send();
      //
      // 6. Handle response
      //    if (response.statusCode == 201) {
      //      var responseData = await response.stream.bytesToString();
      //      var data = json.decode(responseData);
      //      return KegiatanDetail.fromJson(data['data']);
      //    } else if (response.statusCode == 400) {
      //      throw Exception('Validation error - check form inputs');
      //    } else if (response.statusCode == 401) {
      //      throw Exception('Unauthorized - Please login again');
      //    } else {
      //      throw Exception('Failed to create kegiatan: ${response.reasonPhrase}');
      //    }

      throw Exception('Not implemented in dummy mode');
    } catch (e) {
      throw Exception('Error creating kegiatan: $e');
    }
  }
}
