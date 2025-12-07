import 'package:flutter/material.dart';
import '../models/kegiatan_detail.dart';

/// Widget untuk menampilkan informasi detail kegiatan
/// Menampilkan: Title, Category Badge, Tanggal, Lokasi, Penanggung Jawab, Dibuat Oleh
class DetailKegiatanInfo extends StatelessWidget {
  final KegiatanDetail detail;

  const DetailKegiatanInfo({Key? key, required this.detail}) : super(key: key);

  /// Parse hex color string ke Color
  Color _parseColor(String colorString) {
    try {
      final color = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryBgColor = _parseColor(detail.categoryColor);
    final categoryTextColor = _parseColor(detail.categoryTextColor);

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
        spacing: 16,
        children: [
          // Title dan Category Badge
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              // Title
              Text(
                detail.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),

              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                decoration: ShapeDecoration(
                  color: categoryBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  detail.category,
                  style: TextStyle(
                    color: categoryTextColor,
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),

          // Info items (Tanggal, Lokasi, Penanggung Jawab, Dibuat Oleh)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              // Tanggal
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Tanggal',
                value: detail.formattedDate,
              ),

              // Lokasi
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Lokasi',
                value: detail.location,
              ),

              // Penanggung Jawab
              _buildInfoRow(
                icon: Icons.person,
                label: 'Penanggung Jawab',
                value: detail.responsiblePerson,
              ),

              // Dibuat Oleh
              _buildInfoRow(
                icon: Icons.admin_panel_settings,
                label: 'Dibuat Oleh',
                value: detail.createdBy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build info row dengan icon, label dan value
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
