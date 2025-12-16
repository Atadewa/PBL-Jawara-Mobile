import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/layouts/main_layout.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/providers/user_context_provider.dart';

import '../../data/models/aspirasi_model.dart';
import '../providers/aspiration_provider.dart';
import '../widgets/aspirasi_card.dart';
import 'aspirasi_detail_page.dart';
import 'create_aspirasi_page.dart';

class AspirasiPage extends StatefulWidget {
  const AspirasiPage({super.key});

  @override
  State<AspirasiPage> createState() => _AspirasiPageState();
}

class _AspirasiPageState extends State<AspirasiPage> {
  final TextEditingController _searchController = TextEditingController();
  AspirationStatus? _selectedStatus;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));

    // Load data after frame is built to ensure provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _loadData();
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<AspirationProvider>();
    try {
      await provider.fetchList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  List<AspirationModel> _applyFilters(List<AspirationModel> data) {
    var result = List<AspirationModel>.from(data);

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
                (item.creatorName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return result;
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateAspirasiPage()),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _openDetail(AspirationModel aspiration) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AspirasiDetailPage(aspirationId: aspiration.id),
      ),
    );

    if (updated == true) {
      _refresh();
    }
  }

  Future<void> _editAspiration(AspirationModel aspiration) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAspirasiPage(initialAspiration: aspiration),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _deleteAspiration(AspirationModel aspiration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aspirasi'),
        content: const Text('Apakah Anda yakin ingin menghapus aspirasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = context.read<AspirationProvider>();
    try {
      await provider.deleteMyAspiration(aspiration.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aspirasi berhasil dihapus')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal menghapus aspirasi';
        if (e.toString().contains('403') ||
            e.toString().contains('Forbidden')) {
          errorMessage = 'Tidak punya akses untuk melakukan aksi ini';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$errorMessage: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final roles = userContext.roles;

    // Check if user is moderator
    final isModerator = roles.any(
      (role) => [
        'admin',
        'ketua_rw',
        'ketua_rt',
        'sekretaris',
      ].contains(role.toLowerCase()),
    );

    // Warga-only: warga AND NOT moderator
    final isWargaOnly =
        roles.any((r) => r.toLowerCase() == 'warga') && !isModerator;
    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        floatingActionButton: isWargaOnly
            ? FloatingActionButton(
                key: const Key('aspirasi_add_fab'),
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                onPressed: _openCreate,
                child: const Icon(Icons.add),
              )
            : null,
        body: Column(
          children: [
            _buildHeader(isWargaOnly: isWargaOnly, isModerator: isModerator),
            Expanded(child: _buildAspirasiList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isWargaOnly, required bool isModerator}) {
    final title = isModerator ? 'Semua Aspirasi' : 'Aspirasi Saya';
    final subtitle = isModerator
        ? 'Kelola dan moderasi aspirasi warga'
        : 'Daftar aspirasi yang Anda kirimkan';

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
          padding: const EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: 16,
          ),
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspirasiList() {
    return Consumer<AspirationProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.items.isEmpty) {
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
                      provider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final aspirasiList = _applyFilters(provider.items);

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
              final aspiration = aspirasiList[aspirasiIndex];

              final userContext = context.watch<UserContextProvider>();
              final roles = userContext.roles;
              final isModerator = roles.any(
                (role) => [
                  'admin',
                  'ketua_rw',
                  'ketua_rt',
                  'sekretaris',
                ].contains(role.toLowerCase()),
              );
              final isWargaOnly =
                  roles.any((r) => r.toLowerCase() == 'warga') && !isModerator;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: aspirasiIndex < aspirasiList.length - 1 ? 12 : 0,
                ),
                child: AspirasiCard(
                  aspirasi: aspiration,
                  onTap: () => _openDetail(aspiration),
                  showActions: isWargaOnly,
                  onEdit: isWargaOnly
                      ? () => _editAspiration(aspiration)
                      : null,
                  onDelete: isWargaOnly
                      ? () => _deleteAspiration(aspiration)
                      : null,
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
    final statuses = <AspirationStatus?>[
      null,
      AspirationStatus.pending,
      AspirationStatus.inProgress,
      AspirationStatus.resolved,
      AspirationStatus.rejected,
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
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.borderMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
