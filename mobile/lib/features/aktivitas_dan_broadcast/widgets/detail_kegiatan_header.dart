import 'package:flutter/material.dart';
import '../models/kegiatan_detail.dart';

/// Widget header untuk detail kegiatan dengan gradient background
class DetailKegiatanHeader extends StatelessWidget {
  final KegiatanDetail detail;

  const DetailKegiatanHeader({Key? key, required this.detail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Header title
          const Text(
            'Detail Kegiatan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
