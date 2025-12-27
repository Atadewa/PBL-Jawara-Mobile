import 'package:mobile/features/aktivitas_dan_broadcast/models/kegiatan.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/models/broadcast.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/models/kegiatan_detail.dart';

/// Mock service untuk testing fitur Aktivitas & Broadcast
/// Menyediakan data dummy tanpa perlu koneksi API
class MockAktivitasService {
  /// Mode untuk testing berbagai scenario
  final MockMode mode;

  MockAktivitasService({this.mode = MockMode.normal});

  /// Get list kegiatan dummy
  Future<List<Kegiatan>> getKegiatanList({
    String? search,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to fetch kegiatan');
    }

    if (mode == MockMode.empty) {
      return [];
    }

    final dummyData = _getMockKegiatanList();

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

  /// Get list broadcast dummy
  Future<List<Broadcast>> getBroadcastList({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to fetch broadcast');
    }

    if (mode == MockMode.empty) {
      return [];
    }

    return _getMockBroadcastList();
  }

  /// Get kegiatan detail by ID
  Future<Kegiatan> getKegiatanDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to fetch kegiatan detail');
    }

    final list = _getMockKegiatanList();
    return list.firstWhere((k) => k.id == id, orElse: () => list.first);
  }

  /// Get broadcast detail by ID
  Future<Broadcast> getBroadcastDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to fetch broadcast detail');
    }

    final list = _getMockBroadcastList();
    return list.firstWhere((b) => b.id == id, orElse: () => list.first);
  }

  /// Load activity data (kegiatan + broadcast)
  Future<Map<String, dynamic>> loadActivityData() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to load activity data');
    }

    return {
      'kegiatan': mode == MockMode.empty ? [] : _getMockKegiatanList(),
      'broadcast': mode == MockMode.empty ? [] : _getMockBroadcastList(),
    };
  }

  /// Delete kegiatan (mock)
  Future<bool> deleteKegiatan(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to delete kegiatan');
    }

    return true;
  }

  /// Delete broadcast (mock)
  Future<bool> deleteBroadcast(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to delete broadcast');
    }

    return true;
  }

  /// Create kegiatan (mock)
  Future<Kegiatan> createKegiatan(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to create kegiatan');
    }

    return Kegiatan(
      id: 'kegiatan_new',
      title: data['title'] ?? 'New Kegiatan',
      category: data['category'] ?? 'Lainnya',
      categoryColor: '#E0E7FF',
      categoryTextColor: '#432DD7',
      date: data['date'] ?? '1 Januari 2026',
      organizer: data['organizer'] ?? 'System',
      categoryIcon: 'other',
    );
  }

  /// Create broadcast (mock)
  Future<Broadcast> createBroadcast(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (mode == MockMode.error) {
      throw Exception('Mock API Error: Failed to create broadcast');
    }

    return Broadcast(
      id: 'broadcast_new',
      title: data['title'] ?? 'New Broadcast',
      description: data['description'] ?? 'Description',
      createdAt: DateTime.now(),
      createdBy: 'System',
    );
  }

  /// Search kegiatan
  Future<List<Kegiatan>> searchKegiatan(String query) async {
    return getKegiatanList(search: query);
  }

  /// Get kategori kegiatan
  Future<List<String>> getKategoriKegiatan() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return [
      'Kebersihan',
      'Perayaan',
      'Rapat',
      'Kesehatan',
      'Keagamaan',
      'Lainnya',
    ];
  }

  // ==================== MOCK DATA ====================

  List<Kegiatan> _getMockKegiatanList() {
    return [
      Kegiatan(
        id: 'kegiatan_001',
        title: 'Gotong Royong Bulanan',
        category: 'Kebersihan',
        categoryColor: '#DBEAFE',
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
  }

  List<Broadcast> _getMockBroadcastList() {
    return [
      Broadcast(
        id: 'broadcast_001',
        title: 'Pengumuman Iuran Bulanan November',
        description:
            'Kepada seluruh warga RT 01/RW 05, dimohon untuk membayar iuran bulanan November paling lambat tanggal 25 November 2025.',
        createdAt: DateTime(2025, 11, 20),
        createdBy: 'Ketua RT',
      ),
      Broadcast(
        id: 'broadcast_002',
        title: 'Jadwal Penyemprotan Fogging',
        description:
            'Akan dilaksanakan penyemprotan fogging di lingkungan RT 01 pada hari Minggu, 1 Desember 2025 pukul 06.00 WIB.',
        createdAt: DateTime(2025, 11, 25),
        createdBy: 'Ketua RT',
      ),
      Broadcast(
        id: 'broadcast_003',
        title: 'Pemadaman Listrik Terencana',
        description:
            'PLN akan melakukan pemadaman listrik terencana pada tanggal 3 Desember 2025 pukul 09.00 - 15.00 WIB.',
        createdAt: DateTime(2025, 11, 28),
        createdBy: 'Sekretaris RT',
      ),
      Broadcast(
        id: 'broadcast_004',
        title: 'Rapat Koordinasi Akhir Tahun',
        description:
            'Mengundang seluruh pengurus RT untuk menghadiri rapat koordinasi akhir tahun pada Sabtu, 20 Desember 2025.',
        createdAt: DateTime(2025, 12, 1),
        createdBy: 'Ketua RT',
      ),
    ];
  }
}

/// Mode untuk testing berbagai scenario
enum MockMode {
  /// Normal mode dengan data lengkap
  normal,

  /// Empty mode tanpa data
  empty,

  /// Error mode yang throw exception
  error,

  /// Loading mode dengan delay panjang
  loading,
}
