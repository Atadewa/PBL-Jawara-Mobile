import 'package:flutter/material.dart';
import '../../../core/layouts/main_layout.dart';
import '../../../core/routes/app_routes.dart';
import '../models/kegiatan.dart';
import '../models/broadcast.dart';
import '../services/aktivitas_service.dart';
import '../widgets/kegiatan_card.dart';
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
  final AktivitasService _aktivitasService = AktivitasService();
  late TabController _tabController;

  bool _isLoading = true;
  List<Kegiatan> _kegiatanList = [];
  List<Broadcast> _broadcastList = [];
  String? _errorMessage;

  // Filter
  String? _selectedCategory;
  List<String> _categories = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load data dari API
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _aktivitasService.loadActivityData();

      if (!mounted) return;

      setState(() {
        _kegiatanList = data['kegiatan'] as List<Kegiatan>;
        _broadcastList = data['broadcast'] as List<Broadcast>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load kategori kegiatan untuk filter
  Future<void> _loadCategories() async {
    try {
      final categories = await _aktivitasService.getKategoriKegiatan();
      if (!mounted) return;

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Ignore error loading categories
    }
  }

  /// Handle search
  Future<void> _onSearchChanged() async {
    // Debounce search untuk menghindari terlalu banyak API call
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final results = await _aktivitasService.searchKegiatan(
        _searchController.text,
      );

      if (!mounted) return;

      setState(() {
        _kegiatanList = results;
      });
    } catch (e) {
      // Handle error
    }
  }

  /// Handle filter kategori
  Future<void> _onCategoryChanged(String? category) async {
    setState(() {
      _selectedCategory = category;
    });

    try {
      final results = await _aktivitasService.getKegiatanList(
        category: category,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      if (!mounted) return;

      setState(() {
        _kegiatanList = results;
      });
    } catch (e) {
      // Handle error
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
          // FAB
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addKegiatan).then((
                  result,
                ) {
                  // Refresh list jika ada kegiatan baru
                  if (result == true) {
                    setState(() {
                      // Reload kegiatan list
                    });
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
              const SizedBox(height: 16),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kegiatan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Kegiatan Tab
  Widget _buildKegiatanTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kegiatan list
            if (_kegiatanList.isEmpty)
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
                itemCount: _kegiatanList.length,
                itemBuilder: (context, index) {
                  final kegiatan = _kegiatanList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KegiatanCard(
                      kegiatan: kegiatan,
                      onTap: () {
                        // TODO: Navigate to detail kegiatan page
                        _handleKegiatanTap(kegiatan);
                      },
                      onMoreTap: () {
                        // TODO: Show more options (edit, delete, etc)
                        _handleMoreTap(kegiatan);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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

  /// Handle kegiatan tap - Navigate to detail page
  void _handleKegiatanTap(Kegiatan kegiatan) {
    Navigator.pushNamed(
      context,
      AppRoutes.detailKegiatan,
      arguments: kegiatan.id,
    ).then((refreshList) {
      // If delete button was pressed and kegiatan was deleted, refresh the list
      if (refreshList == true) {
        _loadData();
      }
    });
  }

  /// Handle more options tap
  void _handleMoreTap(Kegiatan kegiatan) {
    // TODO: Show bottom sheet with options (edit, delete, share, etc)
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit kegiatan page
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Delete kegiatan with confirmation
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share kegiatan
              },
            ),
          ],
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
}
