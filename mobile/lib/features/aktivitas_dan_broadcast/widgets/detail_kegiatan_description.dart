import 'package:flutter/material.dart';
import '../models/kegiatan_detail.dart';

/// Widget untuk menampilkan deskripsi kegiatan
class DetailKegiatanDescription extends StatelessWidget {
  final KegiatanDetail detail;

  const DetailKegiatanDescription({Key? key, required this.detail})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21.27),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.28, color: Color(0xFFF2F4F6)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Title
          const Text(
            'Deskripsi',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),

          // Description text
          Text(
            detail.description,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
          ),
        ],
      ),
    );
  }
}
