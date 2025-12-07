import 'package:flutter/material.dart';
import 'package:mobile/core/layouts/main_layout.dart';
import 'package:mobile/core/theme/app_colors.dart';

import '../../data/models/aspirasi_model.dart';
import '../../data/services/aspirasi_service.dart';
import '../widgets/aspirasi_card.dart';
import 'aspirasi_detail_page.dart';
import 'create_aspirasi_page.dart';

class AspirasiPage extends StatefulWidget {
  const AspirasiPage({super.key});

  @override
  State<AspirasiPage> createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage>
    with SingleTickerProviderStateMixin {
  final AspirasiService _aspirasiService = AspirasiService();
  final TextEditingController _searchController = TextEditingController();

  AspirasiStatus? _selectedStatus;
  late TabController _tabController;
  late Future<List<Aspirasi>> _futureAll;
  late Future<List<Aspirasi>> _futureMine;

  static const String _currentUserId = 'user-1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
    _futureAll = _aspirasiService.getAllAspirasi();
    _futureMine = _aspirasiService.getAspirasiByUser(_currentUserId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureAll = _aspirasiService.getAllAspirasi();
      _futureMine = _aspirasiService.getAspirasiByUser(_currentUserId);
    });
    await Future.wait([_futureAll, _futureMine]);
  }

  List<Aspirasi> _applyFilters(List<Aspirasi> data, {required bool onlyMine}) {
    var result = List<Aspirasi>.from(data);

    if (_selectedStatus != null) {
      result = result.where((item) => item.status == _selectedStatus).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (item) =>
                item.title.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query) ||
                item.createdBy.toLowerCase().contains(query),
          )
          .toList();
    }

    if (onlyMine) {
      result = result
          .where(
            (item) =>
                item.createdById.toLowerCase() == _currentUserId.toLowerCase(),
          )
          .toList();
    }

    return result;
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<Aspirasi>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAspirasiPage(service: _aspirasiService),
      ),
    );

    if (result != null) {
      _refresh();
    }
  }

  Future<void> _openDetail(Aspirasi aspirasi, {required bool fromMyTab}) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AspirasiDetailPage(
          aspirasiId: aspirasi.id,
          service: _aspirasiService,
          isFromMyAspirasiTab: fromMyTab,
        ),
      ),
    );

    if (updated == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showFab = _tabController.index == 1;
    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        floatingActionButton: showFab
            ? FloatingActionButton(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                onPressed: _openCreate,
                child: const Icon(Icons.add),
              )
            : null,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAspirasiTab(future: _futureAll, onlyMine: false),
                  _buildAspirasiTab(future: _futureMine, onlyMine: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [AppColors.success, AppColors.success],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Aspirasi Warga',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar aspirasi yang dikirimkan oleh warga',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.background,
                indicatorWeight: 4,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.background.withValues(
                  alpha: 0.6,
                ),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Semua Aspirasi'),
                  Tab(text: 'Aspirasi Saya'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspirasiTab({
    required Future<List<Aspirasi>> future,
    required bool onlyMine,
  }) {
    return FutureBuilder<List<Aspirasi>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat aspirasi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        if (onlyMine) {
          debugPrint('Aspirasi Saya loaded: ${data.length} items');
        } else {
          debugPrint('Semua Aspirasi loaded: ${data.length} items');
        }

        final aspirasiList = _applyFilters(data, onlyMine: onlyMine);

        if (aspirasiList.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.iconMuted,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada aspirasi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan aspirasi baru melalui tombol +',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: aspirasiList.length + 2, // +2 for search and filter
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [_buildSearchField(), const SizedBox(height: 16)],
                );
              }

              if (index == 1) {
                return Column(
                  children: [_buildFilterSection(), const SizedBox(height: 16)],
                );
              }

              final aspirasiIndex = index - 2;
              final aspirasi = aspirasiList[aspirasiIndex];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: aspirasiIndex < aspirasiList.length - 1 ? 12 : 0,
                ),
                child: AspirasiCard(
                  aspirasi: aspirasi,
                  onTap: () => _openDetail(aspirasi, fromMyTab: onlyMine),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari aspirasi...',
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: const Icon(Icons.search, color: AppColors.iconMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.borderMuted,
            width: 1.1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.borderMuted,
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final statuses = <AspirasiStatus?>[
      null,
      AspirasiStatus.pending,
      AspirasiStatus.diterima,
      AspirasiStatus.ditolak,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Status',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status;
            final label = status?.label ?? 'Semua';
            return ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedStatus = status;
                });
              },
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryDark : AppColors.borderMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
