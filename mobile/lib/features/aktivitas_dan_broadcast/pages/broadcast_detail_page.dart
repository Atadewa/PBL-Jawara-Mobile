import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers/user_context_provider.dart';
import '../models/broadcast.dart';
import '../services/broadcast_service.dart';
import '../widgets/broadcast_detail_header.dart';
import '../widgets/broadcast_detail_content.dart';
import '../widgets/broadcast_detail_attachments.dart';
import '../widgets/broadcast_detail_actions.dart';

/// Detail page untuk menampilkan informasi lengkap dari sebuah broadcast/pengumuman
///
/// Features:
/// - Load broadcast detail dari service (dengan dummy data untuk dev)
/// - Show loading state dengan skeleton
/// - Show error state dengan retry button
/// - Display broadcast content dengan title, date, description
/// - Display attachments (dokumen, foto)
/// - Edit dan delete actions
///
/// API Integration Steps (untuk production):
/// 1. Di aktivitas_service.dart, method getBroadcastDetail() sudah siap
/// 2. Uncomment production code di dalam method tersebut
/// 3. Setup auth token dan base URL
/// 4. Endpoint: GET /api/broadcasts/{id}
/// 5. Response structure: {"data": {broadcast item detail}}
class BroadcastDetailPage extends StatefulWidget {
  /// Broadcast ID yang akan ditampilkan
  final int broadcastId;

  const BroadcastDetailPage({Key? key, required this.broadcastId})
    : super(key: key);

  @override
  State<BroadcastDetailPage> createState() => _BroadcastDetailPageState();
}

class _BroadcastDetailPageState extends State<BroadcastDetailPage> {
  final BroadcastService _broadcastService = BroadcastService();
  late Future<Broadcast> _broadcastFuture;

  @override
  void initState() {
    super.initState();
    _loadBroadcastDetail();
    print('[BroadcastDetailPage] Loading broadcast id: ${widget.broadcastId}');
  }

  void _loadBroadcastDetail() {
    _broadcastFuture = _broadcastService.getBroadcastById(widget.broadcastId);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadBroadcastDetail();
    });
  }

  void _onEditPressed(Broadcast broadcast) {
    // Navigate to edit broadcast page
    Navigator.pushNamed(
      context,
      AppRoutes.editBroadcast,
      arguments: broadcast.id,
    ).then((result) {
      // Refresh data jika ada perubahan
      if (result == true) {
        _onRefresh();
      }
    });
  }

  void _onDeletePressed(Broadcast broadcast) {
    // Show custom delete confirmation dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delete icon with pink background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFB2C36),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Hapus Broadcast?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'Apakah Anda yakin ingin menghapus broadcast "${broadcast.title}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFFF3F4F6),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Delete button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleDelete(broadcast);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB2C36),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDelete(Broadcast broadcast) {
    // TODO: Call API to delete broadcast
    // _aktivitasService.deleteBroadcast(broadcast.id).then((_) {
    //   // Navigate back to aktivitas page and refresh
    //   Navigator.popUntil(context, (route) => route.isFirst);
    //   ScaffoldMessenger.of(context).showSnackBar(...);
    // });

    // DUMMY: Simulate API call then navigate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Broadcast berhasil dihapus'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to previous page (Broadcast List)
    // This will return to the BroadcastPage or AktivitasDanBroadcastPage
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pop(context, true); // Pop detail page, return to broadcast list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<Broadcast>(
        future: _broadcastFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Error state
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // Data loaded successfully
          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final broadcast = snapshot.data!;
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF10B981),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header dengan gradient
                    _buildHeader(),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title, Date, dan Description dalam satu card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF2F4F6),
                                width: 1,
                              ),
                              boxShadow: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  broadcast.title,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 8),

                                // Date with calendar icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(broadcast.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: const Color(0xFFF2F4F6),
                                ),
                                const SizedBox(height: 16),

                                // Description
                                Text(
                                  broadcast.description,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF475569),
                                        height: 1.7,
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Photo card
                          if (broadcast.imageUrl != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF2F4F6),
                                  width: 1,
                                ),
                                boxShadow: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Foto',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: const Color(0xFF0F172A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFFF3F4F6),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        broadcast.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, _) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (broadcast.imageUrl != null)
                            const SizedBox(height: 16),

                          // Document card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF2F4F6),
                                width: 1,
                              ),
                              boxShadow: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  'Dokumen Terlampir',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: const Color(0xFF0F172A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                ),
                                const SizedBox(height: 12),

                                // Document row with background
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      // PDF Icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.description_outlined,
                                            color: Color(0xFF10B981),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Document info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Daftar_Iuran_November_20...',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF0F172A,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Dokumen PDF',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF94A3B8,
                                                    ),
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Download button
                                      ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Download document - coming soon',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF10B981,
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Unduh',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action buttons
                          BroadcastDetailActions(
                            broadcast: broadcast,
                            onEditPressed: () => _onEditPressed(broadcast),
                            onDeletePressed: () => _onDeletePressed(broadcast),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Detail Broadcast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk loading state
  Widget _buildLoadingState() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk error state
  Widget _buildErrorState(String error) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat broadcast',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _onRefresh(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk empty state
  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Broadcast tidak ditemukan',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date to display format
  /// Example: "20 November 2025"
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Check if current user can manage broadcasts
  bool _canManage() {
    final userContext = context.read<UserContextProvider>().userContext;
    if (userContext == null) return false;
    return canManageBroadcastAndEvent(userContext.roles);
  }
}
