import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../models/broadcast.dart';
import '../services/broadcast_service.dart';
import '../widgets/broadcast_header.dart';
import '../widgets/broadcast_card.dart';

/// Halaman untuk menampilkan daftar broadcast/pengumuman
///
/// Features:
/// - Load broadcasts dari service (dengan dummy data untuk dev)
/// - Show loading state dengan skeleton loaders
/// - Show error state dengan retry button
/// - Display broadcasts dalam list yang scrollable
/// - Pull-to-refresh functionality
///
/// API Integration Steps (untuk production):
/// 1. Di aktivitas_service.dart, method getBroadcastList() sudah siap
/// 2. Uncomment production code di dalam method tersebut
/// 3. Setup auth token dan base URL
/// 4. Endpoint: GET /api/broadcasts
/// 5. Response structure: {"data": [broadcast items]}
class BroadcastPage extends StatefulWidget {
  const BroadcastPage({Key? key}) : super(key: key);

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  final BroadcastService _broadcastService = BroadcastService();
  late Future<List<Broadcast>> _broadcastsFuture;

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();

    // Debug log
    print('[BroadcastPage] Initialized - loading broadcasts from backend');
  }

  void _loadBroadcasts() {
    _broadcastsFuture = _broadcastService.getBroadcastList();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadBroadcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dengan gradient background
          BroadcastHeader(onBackPressed: () => Navigator.of(context).pop()),

          // Content area dengan FutureBuilder
          Expanded(
            child: FutureBuilder<List<Broadcast>>(
              future: _broadcastsFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                // Error state
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                // Empty state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // Data loaded successfully
                final broadcasts = snapshot.data!;

                // Debug log
                print('[BroadcastPage] Loaded ${broadcasts.length} broadcasts');

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF6EE7B7),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: broadcasts.length,
                    itemBuilder: (context, index) {
                      final broadcast = broadcasts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BroadcastCard(
                          broadcast: broadcast,
                          onTap: () {
                            // Navigate to broadcast detail page
                            // Parse id as int if it's a String
                            final broadcastId = broadcast.id is int
                                ? broadcast.id as int
                                : int.parse(broadcast.id.toString());
                            Navigator.of(context).pushNamed(
                              AppRoutes.broadcastDetail,
                              arguments: broadcastId,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk loading state
  /// Menampilkan skeleton loaders
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  /// Widget untuk error state
  /// Menampilkan error message dan retry button
  Widget _buildErrorState(String error) {
    return Center(
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
    );
  }

  /// Widget untuk empty state
  /// Ketika tidak ada broadcast data
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada broadcast',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pengumuman terbaru',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
