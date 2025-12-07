import 'package:flutter/material.dart';

/// Widget untuk menampilkan galeri/dokumentasi foto event
class DetailKegiatanDocumentation extends StatelessWidget {
  final List<String> images;

  const DetailKegiatanDocumentation({Key? key, required this.images})
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
        spacing: 16,
        children: [
          // Title
          const Text(
            'Dokumentasi Event',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),

          // Image gallery
          if (images.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: const Center(
                child: Text(
                  'Tidak ada dokumentasi',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                images.length,
                (index) => _buildImageThumbnail(images[index]),
              ),
            ),
        ],
      ),
    );
  }

  /// Build image thumbnail with network image
  Widget _buildImageThumbnail(String imageUrl) {
    return Container(
      width: 107,
      height: 107,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF3F4F6),
            child: const Icon(
              Icons.image_not_supported,
              color: Color(0xFFCBD5E1),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF3F4F6),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF10B981)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
