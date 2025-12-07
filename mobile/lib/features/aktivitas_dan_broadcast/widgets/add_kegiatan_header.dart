import 'package:flutter/material.dart';

/// Header widget untuk halaman tambah kegiatan
/// Menampilkan gradient background dengan back button dan title
class AddKegiatanHeader extends StatelessWidget {
  const AddKegiatanHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
        ),
      ),
      child: Row(
        spacing: 12,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: const CircleBorder(),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Text(
              'Tambah Kegiatan',
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
    );
  }
}
