import 'package:flutter/material.dart';
import '../../../core/layouts/main_layout.dart';
import '../models/kegiatan_detail.dart';
import '../services/aktivitas_service.dart';
import '../widgets/edit_kegiatan_header.dart';
import '../widgets/edit_kegiatan_form.dart';

/// Halaman edit kegiatan dengan form untuk mengubah data kegiatan
///
/// Menampilkan:
/// - Header dengan gradient background
/// - Form untuk edit: nama, kategori, deskripsi, tanggal, lokasi, penanggung jawab
/// - Upload dokumentasi foto
/// - Tombol simpan perubahan
class EditKegiatanPage extends StatefulWidget {
  final String kegiatanId;

  const EditKegiatanPage({Key? key, required this.kegiatanId})
    : super(key: key);

  @override
  State<EditKegiatanPage> createState() => _EditKegiatanPageState();
}

class _EditKegiatanPageState extends State<EditKegiatanPage> {
  late Future<KegiatanDetail> _detailFuture;
  final AktivitasService _service = AktivitasService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _service.getKegiatanDetailPage(widget.kegiatanId);
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
                  const EditKegiatanHeader(),

                  // Form section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: EditKegiatanForm(
                      detail: detail,
                      kegiatanId: widget.kegiatanId,
                      isSaving: _isSaving,
                      onSave: _handleSaveChanges,
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

  /// Handle save changes dari form
  Future<void> _handleSaveChanges(Map<String, dynamic> formData) async {
    setState(() => _isSaving = true);

    try {
      await _service.updateKegiatan(widget.kegiatanId, formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kegiatan berhasil diperbarui')),
        );
        // Kembali ke halaman detail dengan flag refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
