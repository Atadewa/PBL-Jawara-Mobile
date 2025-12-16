import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers/user_context_provider.dart';
import '../models/broadcast.dart';
import '../models/event_model.dart';
import '../services/broadcast_service.dart';
import '../services/event_service.dart';
import '../widgets/broadcast_card.dart';

/// Halaman Aktivitas & Broadcast
/// Menampilkan list kegiatan dan broadcast dengan tab navigation
class AktivitasDanBroadcastPage extends StatefulWidget {
  const AktivitasDanBroadcastPage({Key? key}) : super(key: key);

  @override
  State<AktivitasDanBroadcastPage> createState() =>
      _AktivitasDanBroadcastPageState();
}

class _AktivitasDanBroadcastPageState extends State<AktivitasDanBroadcastPage>
    with SingleTickerProviderStateMixin {
  final BroadcastService _broadcastService = BroadcastService();
  final EventService _eventService = EventService();
  late TabController _tabController;

  bool _isLoading = true;
  List<Broadcast> _broadcastList = [];
  List<EventModel> _eventList = [];
  String? _errorMessage;
  int _currentTabIndex = 0; // Track active tab: 0=Kegiatan, 1=Broadcast

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    _loadData();

    // Debug log
    print('[AktivitasDanBroadcastPage] Initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load data dari API - NO DUMMY DATA
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load broadcasts from backend
      final broadcasts = await _broadcastService.getBroadcastList();

      // Load events from backend
      final events = await _eventService.getEventList();

      if (!mounted) return;

      setState(() {
        _broadcastList = broadcasts;
        _eventList = events;
        _isLoading = false;
      });

      // Debug log
      print(
        '[AktivitasDanBroadcastPage] Loaded ${broadcasts.length} broadcasts, ${events.length} events',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      print('[AktivitasDanBroadcastPage] Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Index 2 = Kegiatan di navbar
      child: Stack(
        children: [
          Container(
            color: const Color(0xFFF8FAFC),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header
                      _buildHeader(),
                      // Tabs
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFF10B981),
                          indicatorWeight: 3,
                          labelColor: const Color(0xFF0F172A),
                          unselectedLabelColor: const Color(0xFF94A3B8),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Kegiatan'),
                            Tab(text: 'Broadcast'),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab Kegiatan
                            _buildKegiatanTab(),
                            // Tab Broadcast
                            _buildBroadcastTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          // FAB - Only show for authorized roles
          // Action depends on active tab
          if (_canManage())
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  // Route based on current tab
                  final routeName = _currentTabIndex == 0
                      ? AppRoutes
                            .addKegiatan // Tab Kegiatan
                      : AppRoutes.addBroadcast; // Tab Broadcast

                  Navigator.pushNamed(context, routeName).then((result) {
                    // Refresh list after create/edit
                    if (result == true) {
                      _loadData();
                    }
                  });
                },
                backgroundColor: const Color(0xFF10B981),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kegiatan & Broadcast',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Kegiatan Tab - Using Events from Backend
  Widget _buildKegiatanTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Events list from backend
            if (_eventList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 48,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada kegiatan',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _eventList.length,
                itemBuilder: (context, index) {
                  final event = _eventList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEventCard(event),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Build Event Card from backend data
  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      onTap: () {
        // Navigate to event detail with correct ID
        print('[AktivitasDanBroadcastPage] Tapped event id: ${event.id}');
        Navigator.pushNamed(
          context,
          AppRoutes.detailKegiatan,
          arguments: event.id,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image or icon
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildEventIcon();
                  },
                ),
              )
            else
              _buildEventIcon(),
            const SizedBox(width: 12),
            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date and time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedTime,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location
                  if (event.location != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build default event icon
  Widget _buildEventIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.event, color: Color(0xFF1347E5), size: 30),
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return const Color(0xFF10B981);
      case 'draft':
        return const Color(0xFF94A3B8);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Build Broadcast Tab
  Widget _buildBroadcastTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _broadcastList.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada broadcast',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _broadcastList.length,
                itemBuilder: (context, index) {
                  final broadcast = _broadcastList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BroadcastCard(
                      broadcast: broadcast,
                      onTap: () {
                        // TODO: Navigate to detail broadcast page
                        _handleBroadcastTap(broadcast);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Handle broadcast tap
  void _handleBroadcastTap(Broadcast broadcast) {
    // Navigate to broadcast detail page
    Navigator.pushNamed(
      context,
      AppRoutes.broadcastDetail,
      arguments: broadcast.id,
    );
  }

  /// Check if current user can manage broadcasts and events
  bool _canManage() {
    final userContext = context.read<UserContextProvider>().userContext;
    if (userContext == null) return false;
    return canManageBroadcastAndEvent(userContext.roles);
  }
}
