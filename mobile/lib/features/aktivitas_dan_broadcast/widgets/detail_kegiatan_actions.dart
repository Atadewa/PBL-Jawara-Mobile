import 'package:flutter/material.dart';

/// Widget untuk menampilkan tombol aksi (Edit dan Delete)
class DetailKegiatanActions extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final bool isDeleting;

  const DetailKegiatanActions({
    Key? key,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.isDeleting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        // Edit button
        GestureDetector(
          onTap: isDeleting ? null : onEditTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: ShapeDecoration(
              color: const Color(0xFF6EE7B7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(Icons.edit, color: Colors.white, size: 20),
                Text(
                  'Edit Kegiatan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delete button
        GestureDetector(
          onTap: isDeleting ? null : onDeleteTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.28, color: Color(0xFFFFC9C9)),
                borderRadius: BorderRadius.circular(16),
              ),
              shadows: [
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x19000000),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                if (isDeleting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFA2B36)),
                    ),
                  )
                else
                  const Icon(Icons.delete, color: Color(0xFFFA2B36), size: 20),
                Text(
                  isDeleting ? 'Menghapus...' : 'Hapus Kegiatan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDeleting
                        ? const Color(0xFFFA2B36).withValues(alpha: 0.5)
                        : const Color(0xFFFA2B36),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
