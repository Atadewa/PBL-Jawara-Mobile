import 'package:flutter/material.dart';
import '../../../core/layouts/main_layout.dart';
import '../models/kegiatan_detail.dart';
import '../services/aktivitas_service.dart';
import '../widgets/add_kegiatan_header.dart';
import '../widgets/add_kegiatan_form.dart';

/// Halaman untuk menambah kegiatan baru
///
/// Menampilkan:
/// - Header dengan gradient background
/// - Form untuk input: nama, kategori, deskripsi, tanggal, lokasi, penanggung jawab
/// - Upload dokumentasi foto
/// - Tombol simpan kegiatan
class AddKegiatanPage extends StatefulWidget {
  const AddKegiatanPage({Key? key}) : super(key: key);

  @override
  State<AddKegiatanPage> createState() => _AddKegiatanPageState();
}

class _AddKegiatanPageState extends State<AddKegiatanPage> {
  final AktivitasService _service = AktivitasService();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Kegiatan tab index
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan gradient background
              const AddKegiatanHeader(),

              // Form section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: AddKegiatanForm(
                  isSaving: _isSaving,
                  onSave: _handleSaveKegiatan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle save kegiatan dari form
  Future<void> _handleSaveKegiatan(Map<String, dynamic> formData) async {
    setState(() => _isSaving = true);

    try {
      // Call service to create kegiatan
      final kegiatan = await _service.createKegiatan(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan berhasil dibuat'),
            backgroundColor: Color(0xFF6EE7B7),
            duration: Duration(seconds: 2),
          ),
        );

        // Kembali ke halaman kegiatan dengan flag refresh
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
            content: Text('Gagal membuat kegiatan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
