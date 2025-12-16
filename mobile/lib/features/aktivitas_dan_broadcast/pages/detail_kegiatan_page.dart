import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers/user_context_provider.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

/// Halaman detail kegiatan dengan informasi lengkap
///
/// Menampilkan:
/// - Header dengan gradient background
/// - Informasi detail kegiatan (tanggal, lokasi, penanggung jawab, dll)
/// - Deskripsi kegiatan
/// - Dokumentasi/gallery foto
/// - Tombol edit dan hapus kegiatan
class DetailKegiatanPage extends StatefulWidget {
  final int kegiatanId;
  const DetailKegiatanPage({Key? key, required this.kegiatanId})
    : super(key: key);

  @override
  State<DetailKegiatanPage> createState() => _DetailKegiatanPageState();
}

class _DetailKegiatanPageState extends State<DetailKegiatanPage> {
  Future<EventModel>? _detailFuture;
  final EventService _eventService = EventService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Load event detail using the int ID passed from constructor
    print('[DetailKegiatanPage] Received eventId: ${widget.kegiatanId}');
    _detailFuture = _eventService.getEventById(widget.kegiatanId);
  }

  /// Reload event detail (used for retry button)
  void _loadEventDetail() {
    setState(() {
      _detailFuture = _eventService.getEventById(widget.kegiatanId);
    });
  }

  /// Handle delete kegiatan dengan custom dialog
  void _handleDeleteKegiatan(EventModel event) {
    // TODO: Implement delete dialog for EventModel
    // For now, show a simple confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text('Apakah Anda yakin ingin menghapus "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKegiatan(event.id.toString());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  /// Delete event dari API (real backend)
  Future<void> _deleteKegiatan(String id) async {
    setState(() => _isDeleting = true);

    try {
      // Call real backend API
      await _eventService.deleteEvent(int.parse(id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kegiatan berhasil dihapus'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        // Kembali ke halaman sebelumnya dengan flag refresh
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
            content: Text('Gagal menghapus kegiatan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  /// Handle edit kegiatan
  void _handleEditKegiatan(EventModel event) {
    Navigator.pushNamed(
      context,
      AppRoutes.editKegiatan,
      arguments: event.id.toString(),
    ).then((result) {
      // Refresh page jika ada perubahan dari edit page
      if (result == true) {
        _loadEventDetail();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Kegiatan tab index
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: _detailFuture == null
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              )
            : FutureBuilder<EventModel>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF10B981),
                      ),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _loadEventDetail();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Success state
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  final event = snapshot.data!;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header dengan gradient background
                        _buildHeader(event),

                        // Content section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          child: Column(
                            children: [
                              // Info section
                              _buildInfoCard(event),

                              const SizedBox(height: 24),

                              // Description section
                              _buildDescriptionCard(event),

                              const SizedBox(height: 24),

                              // Image section (if available)
                              if (event.imageUrl != null &&
                                  event.imageUrl!.isNotEmpty)
                                _buildImageCard(event),

                              const SizedBox(height: 24),

                              // Action buttons (Edit & Delete) - Only show for authorized users
                              if (_canManage()) _buildActionButtons(event),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Build header with gradient background
  Widget _buildHeader(EventModel event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
        ),
      ),
      child: Column(
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
          // Title
          const Text(
            'Detail Kegiatan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Event title
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build info card with event details
  Widget _buildInfoCard(EventModel event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(event.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusLabel(event.status),
              style: TextStyle(
                color: _getStatusColor(event.status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Date
          _buildInfoRow(Icons.calendar_today, 'Tanggal', event.formattedDate),
          const SizedBox(height: 12),
          // Time
          _buildInfoRow(Icons.access_time, 'Waktu', event.formattedTime),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Lokasi', event.location!),
          ],
          const SizedBox(height: 12),
          // Scope
          _buildInfoRow(
            Icons.home_work,
            'Lingkup',
            event.rt != null
                ? 'RW ${event.rw}, RT ${event.rt}'
                : 'RW ${event.rw}',
          ),
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build description card
  Widget _buildDescriptionCard(EventModel event) {
    final description = event.description.trim();
    final hasDescription = description.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasDescription ? description : 'Tidak ada deskripsi',
            style: TextStyle(
              color: hasDescription ? Color(0xFF64748B) : Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Build image card
  Widget _buildImageCard(EventModel event) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          event.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(EventModel event) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleEditKegiatan(event),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF10B981)),
              foregroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isDeleting ? null : () => _handleDeleteKegiatan(event),
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete),
            label: Text(_isDeleting ? 'Menghapus...' : 'Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return const Color(0xFF10B981);
      case 'draft':
        return const Color(0xFF94A3B8);
      case 'archived':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Get status label
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Aktif';
      case 'draft':
        return 'Draft';
      case 'archived':
        return 'Arsip';
      default:
        return status;
    }
  }

  /// Check if current user can manage events
  bool _canManage() {
    final userContext = context.read<UserContextProvider>().userContext;
    if (userContext == null) return false;
    return canManageBroadcastAndEvent(userContext.roles);
  }
}
