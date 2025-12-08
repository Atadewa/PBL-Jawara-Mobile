import 'package:mobile/core/config/api_config.dart';

import '../models/aspirasi_model.dart';

/*
REAL API IMPLEMENTATION GUIDE (replace dummy data below):
1) Inject HTTP client (Dio/http) via constructor for testability.
2) Gunakan base URL dari ApiConfig: final endpoint = '${ApiConfig.baseUrl}/aspirasi';
3) Map response JSON ke Aspirasi.fromJson dan gunakan try/catch untuk error handling.
4) Pertahankan signature async agar alur UI tidak berubah.
*/
class AspirasiService {
  AspirasiService({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  final String _aspirasiEndpoint = '${ApiConfig.baseUrl}/aspirasi';

  // Dummy data untuk simulasi API
  static final List<Aspirasi> _dummyAspirasi = [
    Aspirasi(
      id: 'asp-1',
      title: 'Perbaikan Jalan RT 01',
      description:
          'Mohon perbaikan jalan di RT 01 yang sudah berlubang dan berbahaya untuk pengendara motor',
      status: AspirasiStatus.pending,
      createdById: 'user-1',
      createdBy: 'Budi Santoso',
      createdAt: DateTime(2024, 11, 20),
    ),
    Aspirasi(
      id: 'asp-2',
      title: 'Perbaikan Got Tersumbat',
      description:
          'Got di depan rumah nomor 15 tersumbat dan menyebabkan banjir saat hujan',
      status: AspirasiStatus.pending,
      createdById: 'user-2',
      createdBy: 'Ahmad Fauzi',
      createdAt: DateTime(2024, 11, 22),
    ),
    Aspirasi(
      id: 'asp-3',
      title: 'Renovasi Balai RW',
      description:
          'Balai RW sudah cukup tua dan perlu direnovasi untuk kegiatan warga',
      status: AspirasiStatus.diterima,
      createdById: 'user-1',
      createdBy: 'Hendra Gunawan',
      createdAt: DateTime(2024, 11, 10),
    ),
    Aspirasi(
      id: 'asp-4',
      title: 'Perbaikan Lampu Jalan',
      description: 'Lampu jalan di blok C sering mati, mohon perbaikan.',
      status: AspirasiStatus.ditolak,
      createdById: 'user-3',
      createdBy: 'Sari Widya',
      createdAt: DateTime(2024, 11, 5),
    ),
    Aspirasi(
      id: 'asp-5',
      title: 'Pemasangan Lampu Jalan',
      description: 'Mohon pemasangan lampu jalan di area taman yang masih gelap.',
      status: AspirasiStatus.diterima,
      createdById: 'user-2',
      createdBy: 'Siti Aminah',
      createdAt: DateTime(2024, 11, 21),
    ),
    Aspirasi(
      id: 'asp-6',
      title: 'Perbaikan Saluran Air',
      description:
          'Saluran air di blok B mampet sehingga menyebabkan genangan saat hujan.',
      status: AspirasiStatus.ditolak,
      createdById: 'user-1',
      createdBy: 'Budi Santoso',
      createdAt: DateTime(2024, 11, 19),
    ),
  ];

  /// Ambil semua aspirasi (bisa difilter status & search di UI)
  Future<List<Aspirasi>> getAllAspirasi() async {
    assert(_aspirasiEndpoint.isNotEmpty, 'Base URL harus di-set di ApiConfig');
    return Future.delayed(
      delay,
      () => List<Aspirasi>.from(_dummyAspirasi),
    );
  }

  Future<List<Aspirasi>> getAspirasiByUser(String userId) async {
    return Future.delayed(
      delay,
      () => _dummyAspirasi
          .where((item) => item.createdById == userId)
          .toList(),
    );
  }

  /// Ambil detail aspirasi per ID
  Future<Aspirasi> getAspirasiDetail(String id) async {
    await Future.delayed(delay);
    return _dummyAspirasi.firstWhere(
      (item) => item.id == id,
      orElse: () =>
          throw Exception('Aspirasi tidak ditemukan ($_aspirasiEndpoint/$id)'),
    );
  }

  /// Simulasi create aspirasi baru
  Future<Aspirasi> createAspirasi(AspirasiInput input) async {
    await Future.delayed(delay * 2);

    final newItem = Aspirasi(
      id: 'asp-${DateTime.now().millisecondsSinceEpoch}',
      title: input.title,
      description: input.description,
      status: input.status,
      createdById: input.createdById,
      createdBy: input.createdBy,
      createdAt: DateTime.now(),
    );

    _dummyAspirasi.insert(0, newItem);
    return newItem;
  }

  /// Perbarui isi aspirasi melalui form edit
  Future<Aspirasi> updateAspirasi(String id, AspirasiInput input) async {
    await Future.delayed(delay * 2);

    final index = _dummyAspirasi.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw Exception('Aspirasi tidak ditemukan ($_aspirasiEndpoint/$id)');
    }

    final updated = _dummyAspirasi[index].copyWith(
      title: input.title,
      description: input.description,
      createdById: input.createdById,
      createdBy: input.createdBy,
      status: input.status,
    );

    _dummyAspirasi[index] = updated;
    return updated;
  }

  /// Update status aspirasi (Diterima/Ditolak/Pending)
  Future<Aspirasi> updateAspirasiStatus(
    String id,
    AspirasiStatus status,
  ) async {
    await Future.delayed(delay);

    final index = _dummyAspirasi.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw Exception('Aspirasi tidak ditemukan');
    }

    final updated = _dummyAspirasi[index].copyWith(status: status);
    _dummyAspirasi[index] = updated;
    return updated;
  }

  /// Hapus aspirasi dari daftar (simulasi DELETE API)
  Future<void> deleteAspirasi(String id) async {
    await Future.delayed(delay);
    _dummyAspirasi.removeWhere((item) => item.id == id);
  }
}
