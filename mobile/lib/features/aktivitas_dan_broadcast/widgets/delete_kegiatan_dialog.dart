import 'package:flutter/material.dart';
import '../models/kegiatan_detail.dart';

typedef OnDeleteConfirmedCallback = Future<void> Function();

/// Delete confirmation dialog untuk kegiatan
/// Menampilkan pesan konfirmasi dengan visual menarik sesuai design system
class DeleteKegiatanDialog extends StatefulWidget {
  final KegiatanDetail detail;
  final OnDeleteConfirmedCallback onDeleteConfirmed;

  const DeleteKegiatanDialog({
    Key? key,
    required this.detail,
    required this.onDeleteConfirmed,
  }) : super(key: key);

  @override
  State<DeleteKegiatanDialog> createState() => _DeleteKegiatanDialogState();
}

class _DeleteKegiatanDialogState extends State<DeleteKegiatanDialog> {
  bool _isDeleting = false;

  /// Handle delete button pressed
  Future<void> _handleDeletePressed() async {
    setState(() => _isDeleting = true);

    try {
      // Call the delete callback
      await widget.onDeleteConfirmed();

      if (mounted) {
        // Close dialog
        Navigator.pop(context, true); // true indicates successful deletion
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 364),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 10,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 25,
              offset: const Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                spacing: 12,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Hapus Kegiatan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w600,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // Warning icon dan title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFFE5E5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          'Perhatian!',
                          style: TextStyle(
                            color: Color(0xFFFA2B36),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Anda akan menghapus kegiatan "${widget.detail.title}". Tindakan ini tidak dapat dibatalkan.',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Detail kegiatan yang akan dihapus
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      const Text(
                        'Detail Kegiatan:',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildDetailRow('Nama', widget.detail.title),
                      _buildDetailRow('Kategori', widget.detail.category),
                      _buildDetailRow('Tanggal', widget.detail.formattedDate),
                      _buildDetailRow('Lokasi', widget.detail.location),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                spacing: 12,
                children: [
                  // Batal button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isDeleting ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.28,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Hapus button
                  Expanded(
                    child: GestureDetector(
                      onTap: _isDeleting ? null : _handleDeletePressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: ShapeDecoration(
                          color: _isDeleting
                              ? const Color(0xFFFA2B36).withOpacity(0.5)
                              : const Color(0xFFFA2B36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: [
                            if (!_isDeleting)
                              BoxShadow(
                                color: const Color(0xFFFA2B36).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            if (_isDeleting)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            Text(
                              _isDeleting ? 'Menghapus...' : 'Hapus Kegiatan',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget untuk detail row
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
