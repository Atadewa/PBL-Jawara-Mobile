import 'package:flutter/material.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../models/kegiatan_detail.dart';
import '../services/aktivitas_service.dart';
import '../widgets/detail_kegiatan_header.dart';
import '../widgets/detail_kegiatan_info.dart';
import '../widgets/detail_kegiatan_description.dart';
import '../widgets/detail_kegiatan_documentation.dart';
import '../widgets/detail_kegiatan_actions.dart';
import '../widgets/delete_kegiatan_dialog.dart';

/// Halaman detail kegiatan dengan informasi lengkap
///
/// Menampilkan:
/// - Header dengan gradient background
/// - Informasi detail kegiatan (tanggal, lokasi, penanggung jawab, dll)
/// - Deskripsi kegiatan
/// - Dokumentasi/gallery foto
/// - Tombol edit dan hapus kegiatan
class DetailKegiatanPage extends StatefulWidget {
  final String kegiatanId;

  const DetailKegiatanPage({Key? key, required this.kegiatanId})
    : super(key: key);

  @override
  State<DetailKegiatanPage> createState() => _DetailKegiatanPageState();
}

class _DetailKegiatanPageState extends State<DetailKegiatanPage> {
  late Future<KegiatanDetail> _detailFuture;
  final AktivitasService _service = AktivitasService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.getKegiatanDetailPage(widget.kegiatanId);
  }

  /// Handle delete kegiatan dengan custom dialog
  void _handleDeleteKegiatan(KegiatanDetail detail) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) => DeleteKegiatanDialog(
        detail: detail,
        onDeleteConfirmed: () => _deleteKegiatan(detail.id),
      ),
    ).then((result) {
      // Handle dialog result
      if (result == true) {
        // Dialog closed successfully (user confirmed delete)
        // SnackBar akan ditampilkan dari service layer
      }
    });
  }

  /// Delete kegiatan dari API
  ///
  /// Implementasi dummy untuk development. Untuk production:
  /// 1. Pastikan service.deleteKegiatan() sudah terintegrasi dengan API real
  /// 2. DELETE endpoint: /api/aktivitas/kegiatan/:id
  /// 3. Tambahkan auth token di header request
  /// 4. Handle berbagai HTTP status codes (400, 401, 403, 404, 500)
  /// 5. Refresh list page setelah berhasil delete
  Future<void> _deleteKegiatan(String id) async {
    setState(() => _isDeleting = true);

    try {
      // TODO: API Integration Steps (Implementasi Real API)
      // 1. Service layer sudah memiliki method deleteKegiatan(id)
      //    Lokasi: lib/features/aktivitas_dan_broadcast/services/aktivitas_service.dart
      //
      // 2. Untuk production, uncomment dan setup real HTTP:
      //    final response = await http.delete(
      //      Uri.parse('$baseUrl/api/aktivitas/kegiatan/$id'),
      //      headers: {
      //        'Authorization': 'Bearer $authToken',
      //        'Content-Type': 'application/json',
      //      },
      //    );
      //    if (response.statusCode == 200) {
      //      return true;
      //    } else if (response.statusCode == 401) {
      //      throw Exception('Unauthorized - Token expired');
      //    } else if (response.statusCode == 403) {
      //      throw Exception('Forbidden - Anda tidak memiliki akses');
      //    } else if (response.statusCode == 404) {
      //      throw Exception('Kegiatan tidak ditemukan');
      //    } else {
      //      throw Exception('Gagal menghapus: ${response.reasonPhrase}');
      //    }
      //
      // 3. Refresh list page setelah delete berhasil

      final success = await _service.deleteKegiatan(id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan berhasil dihapus'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        // Kembali ke halaman sebelumnya dengan flag refresh
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(true); // Return true untuk refresh list
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus kegiatan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  /// Handle edit kegiatan
  void _handleEditKegiatan(KegiatanDetail detail) {
    Navigator.pushNamed(
      context,
      AppRoutes.editKegiatan,
      arguments: detail.id,
    ).then((result) {
      // Refresh page jika ada perubahan dari edit page
      if (result == true) {
        setState(() {
          _detailFuture = _service.getKegiatanDetailPage(widget.kegiatanId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Kegiatan tab index
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: FutureBuilder<KegiatanDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _detailFuture = _service.getKegiatanDetailPage(
                            widget.kegiatanId,
                          );
                        });
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            // Success state
            if (!snapshot.hasData) {
              return const Center(child: Text('Data tidak ditemukan'));
            }

            final detail = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header dengan gradient background
                  DetailKegiatanHeader(detail: detail),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      children: [
                        // Info section (tanggal, lokasi, penanggung jawab, dibuat oleh)
                        DetailKegiatanInfo(detail: detail),

                        const SizedBox(height: 24),

                        // Description section
                        DetailKegiatanDescription(detail: detail),

                        const SizedBox(height: 24),

                        // Documentation section
                        DetailKegiatanDocumentation(
                          images: detail.documentationImages,
                        ),

                        const SizedBox(height: 24),

                        // Action buttons (Edit & Delete)
                        DetailKegiatanActions(
                          onEditTap: () => _handleEditKegiatan(detail),
                          onDeleteTap: () => _handleDeleteKegiatan(detail),
                          isDeleting: _isDeleting,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
