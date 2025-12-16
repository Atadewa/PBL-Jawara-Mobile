import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/providers/user_context_provider.dart';

import '../../data/models/aspirasi_model.dart';
import '../providers/aspiration_provider.dart';
import '../widgets/aspirasi_status_chip.dart';
import 'create_aspirasi_page.dart';

class AspirasiDetailPage extends StatefulWidget {
  const AspirasiDetailPage({super.key, required this.aspirationId});

  final int aspirationId;

  @override
  State<AspirasiDetailPage> createState() => _AspirasiDetailPageState();
}

class _AspirasiDetailPageState extends State<AspirasiDetailPage> {
  bool _isProcessing = false;
  bool _hasChanges = false;
  AspirationModel? _aspiration;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    final provider = context.read<AspirationProvider>();
    try {
      final item = await provider.fetchById(widget.aspirationId);
      if (mounted) {
        setState(() {
          _aspiration = item;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadDetail();
  }

  Future<void> _updateStatus(
    AspirationStatus status, {
    String? decisionNote,
  }) async {
    setState(() => _isProcessing = true);
    final provider = context.read<AspirationProvider>();

    try {
      final updated = await provider.moderateStatus(
        id: widget.aspirationId,
        status: status,
        decisionNote: decisionNote,
      );

      if (!mounted) return;
      setState(() {
        _aspiration = updated;
        _hasChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi ${status.label}')),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Gagal memperbarui status';
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        errorMessage = 'Tidak punya akses untuk melakukan aksi ini';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$errorMessage: $e')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _promptRejectReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alasan Penolakan'),
          content: TextField(
            key: const Key('aspirasi_reject_reason_field'),
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan penolakan',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('aspirasi_reject_confirm_button'),
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty) {
      await _updateStatus(AspirationStatus.rejected, decisionNote: reason);
    }
  }

  Future<void> _deleteAspiration() async {
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

    setState(() => _isProcessing = true);
    final provider = context.read<AspirationProvider>();

    try {
      await provider.deleteMyAspiration(widget.aspirationId);
      if (!mounted) return;
      _hasChanges = true;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Gagal menghapus aspirasi';
      if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        errorMessage = 'Tidak punya akses untuk melakukan aksi ini';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Sesi Anda telah berakhir, silakan login kembali';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$errorMessage: $e')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
      await _refresh();
      _hasChanges = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMMM yyyy');
    final userContext = context.watch<UserContextProvider>();
    final roles = userContext.roles;

    // Check roles
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _aspiration == null
                ? (_error != null
                      ? ListView(
                          children: [
                            _buildHeader(),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Gagal memuat detail aspirasi',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _refresh,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleCard(_aspiration!),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    'Dibuat Oleh',
                                    _aspiration!.creatorName ?? '-',
                                    Icons.person,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    'Tanggal',
                                    formatter.format(_aspiration!.createdAt),
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                              ],
                            ),
                            if (_aspiration!.category != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                'Kategori',
                                _aspiration!.category!,
                                Icons.category,
                              ),
                            ],
                            if (isModerator &&
                                _aspiration!.creatorRw != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      'RW',
                                      'RW ${_aspiration!.creatorRw}',
                                      Icons.location_city,
                                    ),
                                  ),
                                  if (_aspiration!.creatorRt != null) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInfoCard(
                                        'RT',
                                        'RT ${_aspiration!.creatorRt}',
                                        Icons.home,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            _buildDescription(_aspiration!.description),
                            if (_aspiration!.decisionNote != null &&
                                _aspiration!.decisionNote!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDecisionNote(_aspiration!.decisionNote!),
                            ],
                            const SizedBox(height: 24),
                            _buildActionButtons(
                              _aspiration!,
                              isWargaOnly: isWargaOnly,
                              isModerator: isModerator,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              BackButton(color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Detail Aspirasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Informasi lengkap aspirasi warga',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(AspirationModel aspiration) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  aspiration.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AspirasiStatusChip(status: aspiration.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'Tidak ada deskripsi' : description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionNote(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Keputusan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderMuted, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AspirationModel aspiration, {
    required bool isWargaOnly,
    required bool isModerator,
  }) {
    // Moderators can update status
    if (isModerator) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Moderator',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('aspirasi_in_progress_button'),
                  icon: const Icon(Icons.pending_actions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      _isProcessing ||
                          aspiration.status == AspirationStatus.inProgress
                      ? null
                      : () => _updateStatus(AspirationStatus.inProgress),
                  label: const Text(
                    'Proses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  key: const Key('aspirasi_resolve_button'),
                  icon: const Icon(Icons.check_circle_outline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed:
                      _isProcessing ||
                          aspiration.status == AspirationStatus.resolved
                      ? null
                      : () => _updateStatus(AspirationStatus.resolved),
                  label: const Text(
                    'Terima',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('aspirasi_reject_button'),
              icon: const Icon(Icons.close),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed:
                  _isProcessing ||
                      aspiration.status == AspirationStatus.rejected
                  ? null
                  : _promptRejectReason,
              label: const Text(
                'Tolak',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    // Warga-only can edit and delete their own aspirations
    if (isWargaOnly) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_delete_button'),
              icon: const Icon(Icons.delete, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing ? null : _deleteAspiration,
              label: const Text(
                'Hapus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              key: const Key('aspirasi_edit_button'),
              icon: const Icon(Icons.edit, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isProcessing
                  ? null
                  : () => _editAspiration(aspiration),
              label: const Text(
                'Edit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
