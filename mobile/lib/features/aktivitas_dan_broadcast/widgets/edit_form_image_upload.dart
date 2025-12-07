import 'package:flutter/material.dart';

typedef OnImageRemovedCallback = void Function(int index);
typedef OnImagesUploadedCallback = void Function(List<String> newImages);

/// Widget untuk upload dan gallery dokumentasi kegiatan
/// Menampilkan thumbnail gambar dengan opsi hapus, dan tombol untuk upload baru
class EditFormImageUpload extends StatefulWidget {
  final String kegiatanId;
  final List<String> images;
  final OnImageRemovedCallback onImageRemoved;
  final OnImagesUploadedCallback onImagesUploaded;

  const EditFormImageUpload({
    Key? key,
    required this.kegiatanId,
    required this.images,
    required this.onImageRemoved,
    required this.onImagesUploaded,
  }) : super(key: key);

  @override
  State<EditFormImageUpload> createState() => _EditFormImageUploadState();
}

class _EditFormImageUploadState extends State<EditFormImageUpload> {
  bool _isUploading = false;

  /// Handle upload button pressed
  void _handleUploadPressed() async {
    // TODO: Implementasi photo picker
    // Langkah-langkah implementasi:
    // 1. Import package 'image_picker': ^0.8.0+0 dari pub.dev
    // 2. Setup iOS permissions di Info.plist:
    //    <key>NSPhotoLibraryUsageDescription</key>
    //    <string>Kami membutuhkan akses ke galeri Anda untuk upload dokumentasi kegiatan</string>
    // 3. Setup Android permissions di AndroidManifest.xml:
    //    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    // 4. Gunakan ImagePicker untuk ambil gambar:
    //    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    //    if (pickedFile != null) {
    //      List<String> uploadedUrls = await service.uploadDocumentationImages(
    //        widget.kegiatanId,
    //        [pickedFile.path],
    //      );
    //      widget.onImagesUploaded(uploadedUrls);
    //    }

    setState(() => _isUploading = true);

    try {
      // Dummy: Simulasi upload dengan delay
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Replace dengan real image picker code di atas
      List<String> newImages = [
        'https://via.placeholder.com/150?text=IMG${DateTime.now().millisecond}',
      ];

      widget.onImagesUploaded(newImages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar berhasil ditambahkan'),
            backgroundColor: Color(0xFF6EE7B7),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Handle remove image button pressed
  void _handleRemoveImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gambar'),
        content: const Text('Apakah Anda yakin ingin menghapus gambar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              widget.onImageRemoved(index);
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFFA2B36)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        // Header
        const Text(
          'Dokumentasi Event',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Gallery preview
        if (widget.images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _ImageThumbnail(
                  imageUrl: widget.images[index],
                  onRemove: () => _handleRemoveImage(index),
                );
              },
            ),
          ),

        // Upload button
        GestureDetector(
          onTap: _isUploading ? null : _handleUploadPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: ShapeDecoration(
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1.28,
                  color: Color(0xFFE5E7EB),
                  strokeAlign: BorderSide.strokeAlignCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              spacing: 8,
              children: [
                if (_isUploading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6EE7B7)),
                    ),
                  )
                else
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF6EE7B7),
                    size: 24,
                  ),
                Text(
                  _isUploading ? 'Mengupload...' : 'Pilih Gambar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isUploading
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF6EE7B7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info text
        const Text(
          'Anda dapat menambahkan hingga 10 gambar. File harus berupa JPG, PNG, atau GIF.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// Thumbnail widget untuk satu gambar dengan delete button
class _ImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    Key? key,
    required this.imageUrl,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image container
        Container(
          width: 120,
          height: 120,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          clipBehavior: Clip.hardEdge,
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
          ),
        ),

        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
