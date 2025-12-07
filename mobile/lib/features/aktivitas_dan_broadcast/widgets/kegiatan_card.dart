import 'package:flutter/material.dart';
import '../models/kegiatan.dart';

/// Widget untuk menampilkan satu item kegiatan dalam bentuk card
///
/// Digunakan pada halaman Aktivitas & Broadcast untuk menampilkan
/// list kegiatan yang dapat di-scroll dan diurutkan berdasarkan tanggal
class KegiatanCard extends StatelessWidget {
  final Kegiatan kegiatan;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const KegiatanCard({
    Key? key,
    required this.kegiatan,
    this.onTap,
    this.onMoreTap,
  }) : super(key: key);

  /// Parse hex color string ke Color
  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      final color = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryBgColor = _parseColor(kegiatan.categoryColor);
    final categoryTextColor = _parseColor(kegiatan.categoryTextColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x19000000),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten utama
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    kegiatan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: ShapeDecoration(
                      color: categoryBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      kegiatan.category,
                      style: TextStyle(
                        color: categoryTextColor,
                        fontSize: 11,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w500,
                        height: 1.27,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        kegiatan.date,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Organizer
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        kegiatan.organizer,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron icon
            const SizedBox(width: 12),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right,
                size: 24,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
